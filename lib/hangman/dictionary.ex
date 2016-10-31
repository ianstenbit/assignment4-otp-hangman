defmodule Hangman.Dictionary do
  use GenServer
  @me :dictionary



  @moduledoc """
  We act as an interface to a wordlist (whose name is hardwired in the
  module attribute `@word_list_file_name`). The list is formatted as
  one word per line.
  """

  @word_list_file_name "assets/words.8800"

  #############################
  # Start of public interface #
  #############################

  @doc """
  Start GenServer and start with the word list.
  """
  def start_link(word_list) do
    GenServer.start_link(__MODULE__, word_list, :name @me  )
  end

  @doc """
  Return a random word from our word list. Whitespace and newlines
  will have been removed.
  """
  @spec random_word() :: binary
  def random_word do
    GenServer.call(@me, { :random_word })
  end

  @doc """
  Return a list of all the words in our word list of a given length.
  Whitespace and newlines will have been removed.
  """
  @spec words_of_length(integer)  :: [ binary ]
  def words_of_length(len) do
    GenServer.call(@me, { :words_of_length, len })
  end

  ###########################
  # GenServer Implmentation #
  ###########################

  # Page 225 of Elixir Text
  def init (word_list) do: { :ok, word_list }

  # Page 225-226 of Elixir Text & Lecture 16
  def handle_call({ :random_word }, _from, state) do
    {
      :reply,
     word_list
     |> random_word,
     state
    }
  end

  # Page 225-226 of Elixir Text & Lecture 16
  def handle_call({ :words_of_length, len }, _from, state) do
    {
      :reply,
      word_list
      |> words_of_length(len),
      state
    }
  end



  ###########################
  # End of public interface #
  ###########################

  defp word_list do
    @word_list_file_name
    |> File.open!
    |> IO.stream(:line)
  end

  # Keeping below so I can call them in handle call

  @doc """
  Return a random word from our word list. Whitespace and newlines
  will have been removed.
  """

  @spec random_word() :: binary
  defp random_word do
    word_list
    |> Enum.random
    |> String.trim
  end

  @doc """
  Return a list of all the words in our word list of a given length.
  Whitespace and newlines will have been removed.
  """
  @spec words_of_length(integer)  :: [ binary ]
  defp words_of_length(len) do
    word_list
    |> Stream.map(&String.trim/1)
    |> Enum.filter(&(String.length(&1) == len))
  end

end
