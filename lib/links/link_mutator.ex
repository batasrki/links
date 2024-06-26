defmodule Links.LinkMutator do
  require Logger

  def update(link, params) do
    params = for {key, val} <- params, is_binary(key), into: %{}, do: {String.to_atom(key), val}
    Logger.info(params)
    Links.Link.update(link, params)
  end

  def create(params) do
    params =
      Map.merge(params, %{
        "added_at" => DateTime.utc_now(),
        "title" => params["url"],
        "state" => "active"
      })

    params = for {key, val} <- params, into: %{}, do: {String.to_atom(key), val}
    result = Links.Link.create(params)

    case result do
      {:ok, _} -> Links.CrawlerService.fetch_title(params)
      {:error, _} -> Logger.info("Invalid record, not trying to fetch the title")
    end

    result
  end

  def change_link(%Links.Link{} = link, params \\ %{}) do
    Links.Link.create_changeset(link, params)
  end
end
