defmodule Hangman.GameServer do
  use GenServer

  alias Hangman.Game, as : Hangman

  @me :game_server

  #############################
  # Start of public interface #
  #############################

  def start_link(word) do
    GenServer.start_link(__MODULE__, Hangman.new_game(word), name: @me)
  end

  def make_move(guess) do
    Genserver.call(@me, { :make_move, guess })
  end

  def word_length do
    Genserver.call(@me, { :word_length })
  end

  def letters_used_so_far do
    GenServer.call(@me, { :letters_used_so_far })
  end

  def turns_left do
    Genserver.call(@me, {:turns_left })
  end

  def word_as_string(reveal \\ false) do
    Genserver.call(@me, { :word_as_string, reveal })
  end

  ###########################
  # GenServer Implmentation #
  ###########################

end
