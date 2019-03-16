defmodule Links.PeriodicImporter do
  use GenServer

  def start_link(opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil)
    :timer.apply_interval(opts[:interval], __MODULE__, :perform, [pid])
    {:ok, pid}
  end

  def perform(pid) do
    GenServer.cast(pid, :perform)
  end

  def handle_cast(:perform, opts) do
    # Links.Repo.
    last_added_at = NaiveDateTime.utc_now()
    Links.PostgresImporter.import(opts[:key], last_added_at)
  end
end
