defmodule LinksWeb.LinkController do
  require Logger
  use LinksWeb, :controller
  alias Links.LinkDisplayer

  def index(conn, params) do
    previous_config_params = get_session(conn, :config_params) || %{}

    atom_params =
      for {key, val} <- params,
          key_in_whitelist?(key),
          into: %{},
          do: {String.to_existing_atom(key), val}

    conn = put_session(conn, :config_params, Map.merge(previous_config_params, atom_params))

    render(conn, "index.html",
      links: Enum.chunk_every(LinkDisplayer.to_list(get_session(conn, :config_params)), 3)
    )
  end

  defp key_in_whitelist?(key) do
    Enum.any?(["page", "per_page", "sort_direction", "archived"], fn i -> i == key end)
  end
end
