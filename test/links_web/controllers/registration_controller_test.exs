defmodule LinksWeb.RegistrationControllerTest do
  use LinksWeb.ConnCase

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Links.Repo)

    on_exit(fn ->
      Links.Repo.delete_all(Links.User)
    end)
  end

  test "/create with no params", %{conn: conn} do
    conn = post(conn, registration_path(conn, :create))
    assert html_response(conn, 200) =~ "email can&#39;t be blank;"
  end

  test "/create with good params", %{conn: conn} do
    conn =
      post(conn, registration_path(conn, :create), %{
        email: "tester@example.com",
        username: "tester"
      })

    assert html_response(conn, 302)
  end

  test "/create with duplicate e-mail", %{conn: conn} do
    create_user()

    conn =
      post(conn, registration_path(conn, :create), %{
        email: "tester@example.com",
        username: "tester"
      })

    assert html_response(conn, 200) =~ "email has already been taken"
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
