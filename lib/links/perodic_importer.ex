defmodule Links.PeriodicImporter do
  use GenServer
  require Logger

  def start_link(opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, opts)
    Logger.info("Starting #{__MODULE__}")
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
    last_added_at_records =
      Links.Repo.by_last_added_at(%{sort_direction: :desc, per_page: 1, page: 1})

    import_with_timestamp(opts[:key], last_added_at_records)
    {:noreply, opts}
  end

  defp import_with_timestamp(key, []) do
    Logger.info("Importing all Redis records")
    Links.PostgresImporter.import(key, nil)
  end

  defp import_with_timestamp(key, records) do
    last_added_timestamp = hd(records).added_at
    Logger.info("Looking for records newer than #{last_added_timestamp}")
    Links.PostgresImporter.import(key, last_added_timestamp)
  end
end
