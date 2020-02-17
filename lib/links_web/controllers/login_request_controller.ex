defmodule LinksWeb.LoginRequestController do
  require Logger
  use LinksWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => %{"email" => email}}) do
    case Links.Accounts.LoginRequests.create(email) do
      {:ok, %{login_request: login_request}, user} ->
        user
        |> Links.Email.login_request(login_request)
        |> Links.Mailer.deliver_now()

        conn
        |> put_flash(:info, "We emailed you a login link. Please check your inbox.")
        |> redirect(to: "/")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "Oops, that email does not exist.")
        |> render("new.html")
    end
  end

  def show(conn, %{"token" => token}) do
    case Links.Accounts.LoginRequests.redeem(token) do
      {:ok, %{session: session}} ->
        conn
        |> put_flash(:info, "Logged in successfully")
        |> put_session(:session_id, session.id)
        |> configure_session(renew: true)
        |> redirect(to: link_path(conn, :index))

      {:error, :expired} ->
        conn
        |> put_flash(:error, "That login request has expired.")
        |> render("new.html")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "That login request is not valid anymore.")
        |> render("new.html")
    end
  end
end
