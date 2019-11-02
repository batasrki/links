defmodule Links.LinkLocationValidator do
  require Logger
  alias Links.Link

  def validate(link, timeout \\ 5000) do
    case HTTPoison.get(link.url, [], timeout: timeout) do
      {:ok, %HTTPoison.Response{status_code: 301, headers: headers}} ->
        Logger.info("Following a 301 redirect for #{link.url}")
        new_location = follow_redirect_with(headers)
        Link.update(link, %{url: new_location})

      {:ok, %HTTPoison.Response{status_code: 302, headers: headers}} ->
        Logger.info("Following a 302 redirect for #{link.url}")
        new_location = follow_redirect_with(headers)
        Link.update(link, %{url: new_location})

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.info("Archiving #{link.url} due to dead link")
        Link.update(link, %{state: "archived"})

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(reason)
    end
  end

  defp follow_redirect_with(headers) do
    location_header =
      Enum.find(headers, fn {header_name, _} ->
        header_name == "Location" || header_name == "location"
      end)

    case location_header do
      {"Location", new_location} -> new_location
      {"location", new_location} -> new_location
    end
  end
end
