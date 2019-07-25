defmodule Links.LinkLocationValidator do
  require Logger

  ## TODO needs tests!
  def validate(link) do
    # case HTTPoison.get!(link.url) do
    #   {:ok, %HTTPoison.Response{status_code: 301, headers: headers}} ->
    #     Logger.info("Following a 301 redirect for #{link.url}")
    #     follow_redirect_with(params, headers)

    #   {:ok, %HTTPoison.Response{status_code: 302, headers: headers}} ->
    #     Logger.info("Following a 302 redirect for #{link.url}")
    #     follow_redirect_with(params, headers)

    #   {:ok, %HTTPoison.Response{status_code: 404}} ->
    #     Logger.info("Archiving #{link.url} due to dead link")
    #     Links.Repo.update(link.id, %{"archive" => true})

    #   {:error, %HTTPoison.Error{reason: reason}} ->
    #     Logger.error(reason)
    # end
  end

  defp follow_redirect_with(params, headers) do
    location_header = Enum.find(headers, fn {header_name, _} -> header_name == "Location" end)
    {"Location", new_location} = location_header
    params = Map.put(params, :new_url, new_location)
    Links.CrawlerService.update_link_location(params)
  end
end
