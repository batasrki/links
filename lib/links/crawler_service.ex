defmodule Links.CrawlerService do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def fetch_title(params) do
    GenServer.cast(__MODULE__, {:title, params})
  end

  def update_link_location(params) do
    GenServer.cast(__MODULE__, {:update_link_location, params})
  end

  @impl GenServer
  def init(_arg) do
    HTTPoison.start()
    {:ok, nil}
  end

  @impl GenServer
  def handle_cast({:title, params}, state) do
    Links.LinkTitleFetcher.get_title(params)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:update_link_location, params}, state) do
    link = Links.Repo.find_by_url(params.url)
    params = Map.put(params, :url, params.new_url)
    Map.delete(params, :new_url)
    Links.LinkMutator.update(link, params)
    {:noreply, state}
  end
end

# def start_link(opts) do
#   {:ok, pid} = GenServer.start_link(__MODULE__, opts)
#   Logger.info("Starting #{__MODULE__}")
#   :timer.apply_interval(opts[:interval], __MODULE__, :perform, [pid])
#   {:ok, pid}
# end

# def init(opts) do
#   {:ok, opts}
# end
