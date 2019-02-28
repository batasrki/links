defmodule LinksWeb.LinkController do
  require Logger
  use LinksWeb, :controller
  alias ParttransEngine.LinkDisplayer

  def index(conn, params) do
    atom_params = for {key, val} <- params, key_in_whitelist?(key), into: %{}, do: {String.to_existing_atom(key), val}
    render conn, "index.html", links: Enum.chunk_every(LinkDisplayer.to_list(atom_params), 3)
  end

  defp key_in_whitelist?(key) do
    Enum.any?(["page", "per_page", "sort_direction", "archived"], fn(i) -> i == key end)
  end
end
