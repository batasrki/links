defmodule Links.CrawlerService do
  use GenServer
  alias Links.Link

  def start_link(_ignore) do
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
    link = Link.find_by_url(params.url)
    params = Map.put(params, :url, params.new_url)
    params = Map.delete(params, :new_url)
    Links.LinkMutator.update(link, params)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:validate_links_urls, state) do
    Link.list(%{}, %{sort_direction: "asc"})
    |> Enum.each(fn link -> Links.LinkLocationValidator.validate(link) end)

    {:noreply, state}
  end
end
