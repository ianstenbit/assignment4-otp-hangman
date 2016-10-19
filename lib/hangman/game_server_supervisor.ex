defmodule GameServerSupervisor do
  use Supervisor

  def start_link arg \\ [] do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do

    children = [
        #The actual game server
        worker(Hangman.GameServer, [],
             id: :hangmanserver,
             restart: :permanent)
    ]

    supervise(children, strategy: :one_for_one)

  end
end
