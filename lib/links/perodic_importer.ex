defmodule Links.PeriodicImporter do
  use GenServer

  def start_link(opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, opts)
    :timer.apply_interval(opts[:interval], __MODULE__, :perform, [pid])
    {:ok, pid}
  end

  def init(opts) do
    {:ok, opts}
  end

  def perform(pid) do
    GenServer.cast(pid, :perform)
  end

  def handle_cast(:perform, opts) do
    last_added_at_record =
      hd(Links.Repo.by_last_added_at(%{sort_direction: :desc, per_page: 1, page: 1}))

    Links.PostgresImporter.import(opts[:key], last_added_at_record.added_at)
    {:noreply, :ok, opts}
  end
end
