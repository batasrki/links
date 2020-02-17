defmodule LinksWeb.RegistrationController do
  use LinksWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, params) do
    result = Links.Accounts.User.create(Map.take(params, ["email", "username"]))

    case result do
      {:ok, _} ->
        redirect(conn, to: link_path(conn, :index))

      {:error, changeset} ->
        message =
          for {k, v} <- changeset.errors, into: "" do
            {msg, _} = v
            "#{k} #{msg}; "
          end

        conn
        |> put_flash(:error, message)
        |> render("new.html")
    end
  end
end
