defmodule LinksWeb.LinkController do
  require Logger
  use LinksWeb, :controller
  alias Links.{LinkReader, LinkMutator}

  def index(conn, params) do
    session = LinksWeb.AuthHelper.logged_in?(conn)

    if session do
      previous_config_params = get_session(conn, :config_params) || %{}

      atom_params =
        for {key, val} <- params,
            key_in_whitelist?(key),
            into: %{},
            do: {String.to_existing_atom(key), val}

      previous_config_params =
        if Enum.empty?(atom_params) do
          %{sort_direction: "asc", user_id: session.user_id}
        else
          previous_config_params
        end

      conn = put_session(conn, :config_params, Map.merge(previous_config_params, atom_params))
      links = LinkReader.to_list(get_session(conn, :config_params))
      last_record = Enum.reverse(links) |> Enum.at(0)
      render(conn, "index.html", links: links, last_record: last_record)
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
    if LinksWeb.AuthHelper.logged_in?(conn) do
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
  end
  def create(conn, params) do
    session = LinksWeb.AuthHelper.logged_in?(conn)

    if session do
      link_params = Map.take(params, ["title", "client", "url"])
                    |> Map.merge(%{"user_id" => session.user_id})

      result = LinkMutator.create(link_params)

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
    else
    end
  end

  defp key_in_whitelist?(key) do
    Enum.any?(["per_page", "after", "sort_direction", "state"], fn i -> i == key end)
  end
end
