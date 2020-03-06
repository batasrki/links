defmodule LinksWeb.LinkController do
  require Logger
  use LinksWeb, :controller
  alias Links.{LinkReader, LinkMutator}

  def index(conn, params) do
    if LinksWeb.AuthHelper.logged_in?(conn) do
      previous_config_params = get_session(conn, :config_params) || %{}

      atom_params =
        for {key, val} <- params,
            key_in_whitelist?(key),
            into: %{},
            do: {String.to_existing_atom(key), val}

      previous_config_params =
        if Enum.empty?(atom_params) do
          %{sort_direction: "asc"}
        else
          previous_config_params
        end

      conn = put_session(conn, :config_params, Map.merge(previous_config_params, atom_params))

      render(conn, "index.html", links: LinkReader.to_list(get_session(conn, :config_params)))
    else
      redirect(conn, to: login_request_path(conn, :new))
    end
  end

  def edit(conn, params) do
    if LinksWeb.AuthHelper.logged_in?(conn) do
      link = LinkReader.by_id_for_editing(params["id"])

      case link do
        {:error, :not_found} ->
          conn |> put_status(:not_found) |> put_view(LinksWeb.ErrorView) |> render("404.html")

        _ ->
          render(conn, "edit.html", link: link)
      end
    else
      redirect(conn, to: login_request_path(conn, :new))
    end
  end

  def update(conn, params) do
    link = LinkReader.by_id_for_editing(params["id"])
    result = LinkMutator.update(link.data, Map.take(params["link"], ["title", "client", "url"]))

    case result do
      {:ok, _} ->
        redirect(conn, to: link_path(conn, :index, get_session(conn, :config_params)))

      {:error, changeset} ->
        conn
        |> render("edit.html", link: changeset)
    end
  end

  def create(conn, params) do
    result = LinkMutator.create(Map.take(params, ["title", "client", "url"]))

    case result do
      {:ok, _} ->
        redirect(conn, to: link_path(conn, :index, get_session(conn, :config_params)))

      {:error, changeset} ->
        message =
          for {k, v} <- changeset.errors, into: "" do
            {msg, _} = v
            "#{k} #{msg}. "
          end

        conn
        |> put_flash(:error, message)
        |> render("index.html",
          links: Enum.chunk_every(LinkReader.to_list(get_session(conn, :config_params)), 3)
        )
    end
  end

  defp key_in_whitelist?(key) do
    Enum.any?(["per_page", "after", "sort_direction", "state"], fn i -> i == key end)
  end
end
