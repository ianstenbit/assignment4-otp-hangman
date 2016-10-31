defmodule GameTest do
  use ExUnit.Case

  alias Hangman.GameServer, as: Game


  describe "word access functions" do

    setup do
      start_server("wibble")
      :ok
    end

    test "return the length" do
      assert Game.word_length == 6
    end

    test "return the revealed string" do
      assert Game.word_as_string(true) == "w i b b l e"
    end

    test "return the hidden string" do
      assert Game.word_as_string == "_ _ _ _ _ _"
    end
  end


  describe "initial values of " do
    setup do
      start_server("wibble")
      :ok
    end

    test "letters used is []" do
      assert Game.letters_used_so_far == []
    end

    test "turns left is 10" do
      assert Game.turns_left == 10
    end
  end

  describe "correct guess" do
    setup do
      start_server("wibble")
      status = Game.make_move("b")
      [ status: status, guess: "b" ]
    end

    test "returns :good_guess status", t do
      assert :good_guess == t.status
    end

    test "returns a new game state with the letters filled in" do
      assert Game.word_as_string == "_ _ b b _ _"
    end

    test "appears in letters used" do
      assert Game.letters_used_so_far == [ "b" ]
    end

    test "doesn't change 'turns left'" do
      assert Game.turns_left == 10
    end

  end


  describe "incorrect guess" do
    setup do
      start_server("wibble")
      status = Game.make_move("a")
      [ status: status, guess: "a" ]
    end

    test "returns :bad_guess status", t do
      assert :bad_guess == t.status
    end

    test "returns a new game state with no letters filled in" do
      assert Game.word_as_string == "_ _ _ _ _ _"
    end

    test "appears in letters used" do
      assert Game.letters_used_so_far == [ "a" ]
    end

    test "reduces 'turns left'" do
      assert Game.turns_left == 9
    end

  end

  @winning_states [
    { "a", "_ _ _ _ _ _", :bad_guess,  9, [ "a" ] },
    { "b", "_ _ b b _ _", :good_guess, 9, [ "a", "b" ] },
    { "w", "w _ b b _ _", :good_guess, 9, [ "a", "b", "w" ] },
    { "i", "w i b b _ _", :good_guess, 9, [ "a", "b", "i", "w" ] },
    { "l", "w i b b l _", :good_guess, 9, [ "a", "b", "i", "l", "w" ] },
    { "x", "w i b b l _", :bad_guess,  8, [ "a", "b", "i", "l", "w", "x" ] },
    { "e", "w i b b l e", :won,        8, [ "a", "b", "e", "i", "l", "w", "x" ] },
  ]

  describe "a winning game" do

    test "progresses through the states" do
      start_server("wibble")

      Enum.each(@winning_states,  fn ({ guess, was, stat, left, used }) ->
        status = Game.make_move(guess)

        assert status == stat
        assert Game.word_as_string == was
        assert (Game.letters_used_so_far |> Enum.sort) == used
        assert Game.turns_left == left
      end)

      Game.crash(:normal)
    end

  end

  @losing_states [
    { "a", "_ _ _ _ _ _", :bad_guess,  9, [ "a" ] },
    { "b", "_ _ b b _ _", :good_guess, 9, [ "a", "b" ] },
    { "c", "_ _ b b _ _", :bad_guess,  8, [ "a", "b", "c" ] },
    { "d", "_ _ b b _ _", :bad_guess,  7, [ "a", "b", "c", "d" ] },
    { "e", "_ _ b b _ e", :good_guess, 7, [ "a", "b", "c", "d", "e" ] },
    { "f", "_ _ b b _ e", :bad_guess,  6, [ "a", "b", "c", "d", "e", "f" ] },
    { "g", "_ _ b b _ e", :bad_guess,  5, [ "a", "b", "c", "d", "e", "f", "g" ] },
    { "h", "_ _ b b _ e", :bad_guess,  4, [ "a", "b", "c", "d", "e", "f", "g", "h" ] },
    { "j", "_ _ b b _ e", :bad_guess,  3, [ "a", "b", "c", "d", "e", "f", "g", "h", "j" ] },
    { "k", "_ _ b b _ e", :bad_guess,  2, [ "a", "b", "c", "d", "e", "f", "g", "h", "j", "k" ] },
    { "m", "_ _ b b _ e", :bad_guess,  1, [ "a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "m" ] },
    { "n", "_ _ b b _ e", :lost,       0, [ "a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "m", "n" ] },
  ]

  describe "a losing game" do

    test "progresses through the states" do
      start_server("wibble")

      Enum.each(@losing_states, fn ({ guess, was, stat, left, used }) ->
        status = Game.make_move(guess)

        assert status == stat
        assert Game.word_as_string == was
        assert (Game.letters_used_so_far |> Enum.sort) == used
        assert Game.turns_left == left
      end)

      Game.crash(:normal)
    end

  end


  def start_server(word) do
    case Game.start_link(word) do
      { :error, {:already_started, pid}} ->
        GenServer.stop(pid)
        start_server(word)
      { _ok, _ } ->
        nil
    end
  end
  
end
