defmodule Links.LinkTitleFetcher do
  require Logger

  def get_title(params) do
    case HTTPoison.get(params["url"]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        title = parse_title_tag(body)

        Links.Repo.find_by_url(params["url"])
        |> Enum.each(fn record ->
          Links.Repo.update(record.id, %{"title" => title})
        end)

        LinksWeb.Endpoint.broadcast!("updates:*", "incoming", %{title: title})

      {:ok, %HTTPoison.Response{status_code: 301, headers: headers}} ->
        Logger.info("Following a 301 redirect for #{params["url"]}")
        follow_redirect_with(params, headers)

      {:ok, %HTTPoison.Response{status_code: 302, headers: headers}} ->
        Logger.info("Following a 302 redirect for #{params["url"]}")
        follow_redirect_with(params, headers)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.info("Archiving #{params["url"]} due to dead link")

        Links.Repo.find_by_url(params["url"])
        |> Enum.each(fn record ->
          Links.Repo.update(record.id, %{"archive" => true})
        end)

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(reason)
    end
  end

  def parse_title_tag(body) do
    Regex.run(~r{<title.*>\n*\s*(.*)\n*\s*</title>}, body)
    |> List.last()
    |> String.split(">")
    |> List.last()
  end

  defp follow_redirect_with(params, headers) do
    location_header = Enum.find(headers, fn {header_name, _} -> header_name == "Location" end)
    {"Location", new_location} = location_header
    params = Map.put(params, :new_url, new_location)
    Links.CrawlerService.update_link_location(params)
  end
end
