defmodule LinksWeb.LinkController do
  require Logger
  use LinksWeb, :controller
  alias Links.{LinkReader, LinkMutator}

  def index(conn, params) do
    previous_config_params = get_session(conn, :config_params) || %{}

    atom_params =
      for {key, val} <- params,
          key_in_whitelist?(key),
          into: %{},
          do: {String.to_existing_atom(key), val}

    conn = put_session(conn, :config_params, Map.merge(previous_config_params, atom_params))

    render(conn, "index.html",
      links: Enum.chunk_every(LinkReader.to_list(get_session(conn, :config_params)), 3)
    )
  end

  def edit(conn, params) do
    link = LinkReader.by_id(params["id"])

    case link do
      nil -> render(conn, "404.html")
      _ -> render(conn, "edit.html", link: link)
    end
  end

  def update(conn, params) do
    link = LinkReader.by_id(params["id"])
    result = LinkMutator.update(link, Map.take(params, ["title", "client", "url"]))

    case result do
      {:ok, _} ->
        redirect(conn, to: "/")

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("edit.html", link: link)
    end
  end

  def create(conn, params) do
    result = LinkMutator.create(Map.take(params, ["title", "client", "url"]))

    case result do
      {:ok, _} ->
        redirect(conn, to: "/")

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("index.html",
          links: Enum.chunk_every(LinkReader.to_list(get_session(conn, :config_params)), 3)
        )
    end
  end

  defp key_in_whitelist?(key) do
    Enum.any?(["page", "per_page", "sort_direction", "archived"], fn i -> i == key end)
  end
end
