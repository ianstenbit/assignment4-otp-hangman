defmodule Hangman.GameServer do
  use GenServer

  alias Hangman.Game, as: Hangman

  @me :game_server

  #############################
  # Start of public interface #
  #############################

  def start_link,       do: GenServer.start_link(__MODULE__, Hangman.new_game, name: @me)

  def start_link(word) do
    GenServer.start_link(__MODULE__, Hangman.new_game(word), name: @me)
  end

  def make_move(guess) do
    GenServer.call(@me, { :make_move, guess })
  end

  def word_length do
    GenServer.call(@me, { :word_length })
  end

  def letters_used_so_far do
    GenServer.call(@me, { :letters_used_so_far })
  end

  def turns_left do
    GenServer.call(@me, {:turns_left })
  end

  def word_as_string(reveal \\ false) do
    GenServer.call(@me, { :word_as_string, reveal })
  end

  ###########################
  # GenServer Implmentation #
  ###########################

  def init(args), do: { :ok, args }

  def handle_call({ :make_move, guess }, _from, state) do
    { new_state, status, _ } = Hangman.make_move(state, guess)
    {:reply, status, new_state}
  end

  def handle_call({ :word_length }, _from, state) do
    {:reply, Hangman.word_length, state}
  end

  def handle_call({ :letters_used_so_far }, _from, state) do
    {:reply, Hangman.letters_used_so_far, state}
  end

  def handle_call({ :turns_left }, _from, state) do
    {:reply, Hangman.turns_left, state}
  end

  def handle_call({ :word_as_string, reveal }, _from, state) do
    {:reply, Hangman.word_as_string(reveal), state}
  end

end
