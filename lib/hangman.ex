defmodule Hangman do
  use Application

  #   For my supervision strategy, I decided to use a two-tiered supervision tree,
  # where the root supervisor has two children: the dictionary, and another supervisor.
  # This root supervisor uses the one_for_all restart strategy, so that if the dictionary
  # crashes, all of the games will be stopped (the games are supervised by the second-layer
  # supervisor). The second-layer supervisor (which supervises the hangman game servers),
  # in turn, uses a one-for-one strategy, so that whenever a game crashes, that game
  # and that game alone is re-started. For the game server workers, the transient restart
  # strategy is used, because the game should restart, unless it exited normally. For the
  # dictionary worker, the permanent restart strategy is used, because the dictionary
  # must be up at all times, at it is a dependency for the game server workers.

  # Here is an attempt at a drawing of the supervision tree:

            #####################################
            #   Root Supervisor (this module)   #
            #         /            \            #
            #        /              \           #
            #       /                \          #
            # Dictionary        Game Supervisor #
            #                         |         #
            #                         |         #
            #                     GameServer    #
            #####################################

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
        worker(Hangman.Dictionary, [],
             id: :dictionary,
             restart: :permanent
        ),
        supervisor(GameServerSupervisor, [])
    ]

    opts = [strategy: :one_for_all, name: Hangman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
