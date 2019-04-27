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
    most_recent_records =
      Links.Repo.by_last_added_at(%{sort_direction: :desc, per_page: 1, page: 1})

    import_from_last_added_record(opts[:key], most_recent_records)
    {:noreply, opts}
  end

  defp import_from_last_added_record(key, []) do
    Logger.info("Importing all Redis records")
    Links.PostgresImporter.import(key, nil)
  end

  defp import_from_last_added_record(key, records) do
    last_added_record = hd(records)
    Logger.info("Looking for records newer than #{last_added_record.added_at}")
    Links.PostgresImporter.import(key, last_added_record)
  end
end
