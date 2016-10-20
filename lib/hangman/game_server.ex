defmodule Hangman.GameServer do

  use GenServer

  alias Hangman.Game, as: Game
  alias Hangman.Dictionary, as: Dict
  @me :gameserver

  def start_link(word \\ Dict.random_word) do
    GenServer.start __MODULE__, word, name: @me
  end

  def new_game(word \\ Dict.random_word) do
    GenServer.cast @me, {:newGame, word}
  end

  def make_move(guess) do
    GenServer.call @me, {:make_move, guess}
  end

  def word_length do
    GenServer.call @me, {:word_length}
  end

  def letters_used_so_far do
    GenServer.call @me, {:letters}
  end

  def turns_left do
    GenServer.call @me, {:turns_left}
  end

  def word_as_string(reveal \\ false) do
    GenServer.call @me, {:word_as_string, reveal}
  end

  def crash(status) do
    GenServer.cast @me, { :crash, status}
  end

  #Implementation
  def init(word) do
    {:ok, Game.new_game(word)}
  end

  def handle_cast {:newGame, word}, _state do
    {:noreply, Game.new_game(word)}
  end

  def handle_call {:make_move, guess}, _from, state do
    response = Game.make_move(state, guess)
    {:reply, elem(response, 1), elem(response, 0)}
  end

  def handle_call {:word_length}, _from, state do
    {:reply, Game.word_length(state), state}
  end

  def handle_call {:letters}, _from, state do
    {:reply, Game.letters_used_so_far(state), state}
  end

  def handle_call {:turns_left}, _from, state do
    {:reply, Game.turns_left(state), state}
  end

  def handle_call {:word_as_string, reveal}, _from, state do
    {:reply, Game.word_as_string(state, reveal), state}
  end

  def handle_cast {:crash, status}, state do
    {:stop, status, state}
  end

end
