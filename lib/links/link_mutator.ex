defmodule Links.LinkMutator do
  def update(link, params) do
    params = for {key, val} <- params, into: %{}, do: {String.to_atom(key), val}
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

    unless {:error, _} = result do
      Links.CrawlerService.fetch_title(params)
    end

    result
  end
end
