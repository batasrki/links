defmodule LinksWeb.LoginRequestControllerTest do
  use LinksWeb.ConnCase

  test "/new renders log in form", %{conn: conn} do
    conn = get(conn, Routes.login_request_path(conn, :new))
    assert html_response(conn, 200) =~ "E-mail"
  end

  test "/create redirects if login is successful", %{conn: conn} do
    create_user()

    conn =
      post(conn, Routes.login_request_path(conn, :create), %{
        session: %{email: "tester@example.com"}
      })

    assert html_response(conn, 302)
  end

  test "/create renders an error if e-mail is non-existent", %{conn: conn} do
    conn =
      post(conn, Routes.login_request_path(conn, :create), %{
        session: %{email: "tester@example.com"}
      })

    assert html_response(conn, 200) =~ "Oops, that email does not exist."
  end

  defp create_user() do
    user = %{
      username: "tester",
      email: "tester@example.com",
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }

    Links.Repo.insert_all(Links.User, [user])
  end
end
