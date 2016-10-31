defmodule Hangman do
  use Application

  @moduledoc """

  Supervision Scheme Description

  I decided to have a main Hangman Supervisor (hangman.ex) as my tree root.
  It will have two children. First is a Dictionary Server (dictionary.ex - since inline).
  Second is a Game Supervisor (per instructions) that will have a Game Server
  (game_server.ex - since outside style was requirement).

  As per Strategies...(took this from README.md)

  # Game Supervisor

  If the Game exits normally, do nothing. If it crashes, restart it (and just it).
  # A crash would be an abnormal termination, so :transient restart.
  # One game shouldn't affect another game, so supervisor strategy is one_for_one

  # Main Supervisor

  If the Dictionary exits for any reason, kill any game, and restart both the
  Dictionary and the Game.
  # Restart everything, so :permanent restart.
  # Kill all games, so supervisor strategy is :one_for_all

  """

  def start(_type, _args) do

    # Uncomment and complete this:

    import Supervisor.Spec, warn: false

    children = [
      supervisor(Hangman.GameSupervisor, []),
      worker(Hangman.Dictionary, [], restart: :permanent)
    ]

    opts = [strategy: :one_for_all, name: Hangman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
