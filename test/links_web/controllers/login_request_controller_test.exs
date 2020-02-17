defmodule LinksWeb.LoginRequestControllerTest do
  use LinksWeb.ConnCase

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Links.Repo)

    on_exit(fn ->
      Links.Repo.delete_all(Links.User)
    end)
  end

  test "/new renders log in form", %{conn: conn} do
    conn = get(conn, login_request_path(conn, :new))
    assert html_response(conn, 200) =~ "E-mail"
  end

  test "/create redirects if login is successful", %{conn: conn} do
    create_user()

    conn =
      post(conn, login_request_path(conn, :create), %{session: %{email: "tester@example.com"}})

    assert html_response(conn, 302)
  end

  test "/create renders an error if e-mail is non-existent", %{conn: conn} do
    conn =
      post(conn, login_request_path(conn, :create), %{session: %{email: "tester@example.com"}})

    assert html_response(conn, 200) =~ "Oops, that email does not exist."
  end

  defp create_user() do
    user = %{
      username: "tester",
      email: "tester@example.com"
    }

    Links.Repo.insert_all(Links.User, [user])
  end
end
