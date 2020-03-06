defmodule LinksWeb.LinkControllerTest do
  use LinksWeb.ConnCase

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Links.Repo)

    on_exit(fn ->
      Links.Repo.delete_all(Links.Link)
      Links.Repo.delete_all(Links.User)
      Links.Repo.delete_all(Links.Accounts.Session)
    end)
  end

  test "/edit", %{conn: conn} do
    {_, links} = create_link()
    link = links |> hd()
    session = create_session()

    conn =
      session_conn()
      |> put_session(:session_id, session.id)
      |> put_req_header("content-type", "text/html")
      |> get(link_path(conn, :edit, link.id))

    assert html_response(conn, 200) =~ "How To Seed the Test DB"
  end

  test "/edit to a non-existent link returns 404 page", %{conn: conn} do
    session = create_session()

    conn =
      session_conn()
      |> put_session(:session_id, session.id)
      |> put_req_header("content-type", "text/html")
      |> get(link_path(conn, :edit, 2_147_483_647))

    assert html_response(conn, 404) =~ "Not Found"
  end

  test "/edit without being logged in redirects", %{conn: conn} do
    {_, links} = create_link()
    link = links |> hd()
    conn = get(conn, link_path(conn, :edit, link.id))
    assert html_response(conn, 302)
  end

  defp create_link() do
    link = %{
      url: "http://localhost:8081/test/howto.html",
      title: "How To Seed the Test DB",
      state: "active",
      added_at: DateTime.utc_now() |> DateTime.truncate(:second),
      client: "test client",
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }

    Links.Repo.insert_all(Links.Link, [link], returning: [:id])
  end

  defp create_session() do
    {:ok, user} =
      Links.Accounts.User.create_for_session(%{
        email: "test@example.com",
        username: "tester"
      })

    {:ok, session} = Ecto.build_assoc(user, :sessions) |> Links.Repo.insert()
    session
  end
end
