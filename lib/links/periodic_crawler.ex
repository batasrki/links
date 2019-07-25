defmodule Links.PeriodicCrawler do
  use GenServer
  require Logger

  def start_link(opts) do
    {:ok, pid} = GenServer.start_link(__MODULE__, opts)
    Logger.info("Starting #{__MODULE__}")
    :timer.apply_interval(opts[:interval], __MODULE__, :perform, [pid])
    {:ok, pid}
  end

  @impl GenServer
  def init(opts) do
    {:ok, opts}
  end

  def perform(pid) do
    GenServer.cast(pid, :perform)
  end

  @impl GenServer
  def handle_cast(:perform, opts) do
    Logger.info("Crawling all links for liveness check")
    Links.CrawlerService.validate_links_urls()
    {:noreply, opts}
  end
end
