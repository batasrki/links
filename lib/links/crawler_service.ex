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

  def validate_links_urls() do
    GenServer.cast(__MODULE__, :validate_links_urls)
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

  @impl GenServer
  def handle_cast(:validate_links_urls, state) do
    Links.Repo.list(%{})
    |> Enum.each(fn link -> Links.LinkLocationValidator.validate(link) end)

    {:noreply, state}
  end
end
