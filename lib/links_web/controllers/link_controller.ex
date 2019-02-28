defmodule LinksWeb.LinkController do
  require Logger
  use LinksWeb, :controller
  alias ParttransEngine.LinkDisplayer

  def index(conn, params) do
    atom_params = for {key, val} <- params, into: %{}, do: {String.to_existing_atom(key), val}
    render conn, "index.html", links: Enum.chunk_every(LinkDisplayer.to_list(atom_params), 3)
  end
end
