# Hangman—The OTP iteration

It's time to take our Hangman game up a notch.

This assignment takes Hangman and turns it into a supervised set of OTP servers.

We'll be taking two modules, Game and Dictionary, and making servers of each.

These modules will be part of a supervision tree. The constraints of
this supervision are simple:

# Game Supervisor
If the Game exits normally, do nothing. If it crashes, restart it (and just it).

# A crash would be an abnormal termination, so :transient restart.
# One game shouldn't affect another game, so supervisor strategy is :one_for_one

# Main Supervisor
If the Dictionary exits for any reason, kill any game, and restart both the
Dictionary and the Game.

# Restart everything, so :permanent restart.
# Kill all games, so supervisor strategy is :one_for_all

(Hint: you'll need two supervisors.)

I need you to add a single paragraph comment to the top of
`lib/hangman.ex` explaining why you have chosen the supervision
structure that you use.


# Details for 5345 and 7345 Students

Convert the current dictionary module to a GenServer inline (that is, the
dictionary code and the GenServer api and callbacks will all be in the
dictionary module).

You'll register the dictionary server under the name `:dictionary`.

Convert the game to a GenServer using the *outside* style (so you'll
write a separate GameServer module that calls functions in the
existing `game.ex` file. Give the GameServer a name.

You'll need to add top-level supervision to `lib/hangman.ex`, and
you'll need to add a second subsupervisor in `lib/hangman/...`.

Update your `mix.exs` to start the servers automatically (by
referencing the top-level supervisor).


You'll play the game using

~~~ elixir
status = Hangman.GameServer.make_move(guess)
~~~

Where status is one of `:won`, `:lost`, `:good_guess`, or `:bad_guess`.

The other API calls are

~~~
length       = Hangman.GameServer.word_length
letters_used = Hangman.GameServer.letters_used_so_far
turns_left   = Hangman.GameServer.turns_left
word         = Hangman.GameServer.word_as_string(reveal = true|false)
~~~

These behave just like the API in assignment 2.

# A Starting Point

To make my life easier, this project already has a version of the
assignment 2 hangman game. You job is to turn `game.ex` and
`dictionary.ex` into GenServers, and to add the appropriate supervision
tree and support modules.

# Tests

You can use `mix test` to test your code. Right now, all but one of the
tests fail, because they are written for the OTP version of the app.
As you start to add functionality, more and more will pass.

# Grading

A total of 100 marks are available:

50 for a working program (one that passes the tests included here and any
   others I may run wile grading)

10 for a good description of the supervision strategy you use, justifying
   why it meets the requirements above

20 for elegant code

10 for good-looking code

10 for the rest :)

Copying code from other students will be penalized.


# 8k Students

You will do the same as above, but with one small twist.

You will implement the game servers so that you can run an arbitrary
number of them in parallel. To do this, the game server supervisor
will need to use the `simple_one_for_one` strategy, and create worker
processes when requested.

The game supervisor will have a function `new_game` that starts a new
GameServer child process and returns its pid. That child is a GenServer.

You play the game using the GameServer interface. In your case, you'll
need to keep the original first parameter to each call, as you'll need
to pass the pid in.

The game process should terminate normally when the game is either won
or lost. It won't need to be restarted.

So, a sample iex session might be:

~~~
iex> g1 = Hangman.GameSupervisor.new_game
iex> Hangman.GameServer.make_move(g1, "e")
iex> Hangman.GameServer.word_as_string(g1)
"_ _ _ e _ e"
iex> g2 = Hangman.GameSupervisor.new_game
iex> Hangman.GameServer.make_move(g1, "e")
iex> Hangman.GameServer.word_as_string(g2)
"e _ _ _ _ _"
iex> Hangman.GameServer.word_as_string(g1)
"_ _ _ e _ e"
~~~

You'll need to update the tests accordingly.
