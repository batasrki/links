defmodule LinksWeb.LinkControllerTest do
  use LinksWeb.ConnCase

  alias Links.{Link, User, Repo}

  setup %{conn: conn } do
    {:ok, conn: conn, session: create_session() }
  end

  describe "index" do
    test "/index without being logged in, redirects", %{conn: conn} do
      conn = get(conn, Routes.link_path(conn, :index))
      assert html_response(conn, 302)
    end

    test "/index while logged in but no links, shows empty state", %{conn: conn, session: session} do
      conn = conn
      |> init_test_session(%{session_id: session.id})
      |> put_req_header("content-type", "text/html")
      |> get(Routes.link_path(conn, :index))

      assert html_response(conn, 200) =~ "No links right now"
    end

    test "/index while logged in and having a saved link, shows the link", %{conn: conn, session: session} do
       {_, links} = create_link()
      link = links |> hd()

      conn = conn
      |> init_test_session(%{session_id: session.id})
      |> put_req_header("content-type", "text/html")
      |> get(Routes.link_path(conn, :edit, link.id))

      assert html_response(conn, 200) =~ "How To Seed the Test DB"
    end
  end

  describe "create" do
    test "/create works when logged in", %{conn: conn, session: session} do
      create_params = %{
        url: "https://www.example.com",
        client: "test client"
      }

      conn = conn
      |> init_test_session(%{session_id: session.id})
      |> put_req_header("content-type", "text/html")
      |> post(Routes.link_path(conn, :create, create_params))

      assert html_response(conn, 200) =~ "Updating the seed 1"
    end

    test "/create without being logged in redirects", %{conn: conn} do
      conn = post(conn, Routes.link_path(conn, :create, %{title: "title"}))
      assert html_response(conn, 302)
    end
  end

  describe "edit" do
    test "/edit", %{conn: conn} do
      {_, links} = create_link()
      link = links |> hd()
      session = create_session()

      conn =
        session_conn()
        |> put_session(:session_id, session.id)
        |> put_req_header("content-type", "text/html")
        |> get(Routes.link_path(conn, :edit, link.id))

      assert html_response(conn, 200) =~ "How To Seed the Test DB"
    end

    test "/edit to a non-existent link returns 404 page", %{conn: conn} do
      session = create_session()

      conn =
        session_conn()
        |> put_session(:session_id, session.id)
        |> put_req_header("content-type", "text/html")
        |> get(Routes.link_path(conn, :edit, 2_147_483_647))

      assert html_response(conn, 404) =~ "Not Found"
    end

    test "/edit without being logged in redirects", %{conn: conn} do
      {_, links} = create_link()
      link = links |> hd()
      conn = get(conn, Routes.link_path(conn, :edit, link.id))
      assert html_response(conn, 302)
    end
  end

  describe "update" do
    test "/update works when logged in", %{conn: conn} do
      {_, links} = create_link()
      link = links |> hd()
      session = create_session()
      update_params = %{
        title: "Updating the seed"
      }

      conn =
        session_conn()
        |> put_session(:session_id, session.id)
        |> put_session("_csrf_token", Plug.CSRFProtection.get_csrf_token())
        |> put_req_header("content-type", "text/html")
        |> put(Routes.link_path(conn, :update, link.id, link: update_params))

      assert html_response(conn, 200) =~ "Updating the seed 1"
    end

    test "/update to a non-existent link returns 404 page", %{conn: conn} do
      session = create_session()

      conn =
        session_conn()
        |> put_session(:session_id, session.id)
        |> put_req_header("content-type", "text/html")
        |> put(Routes.link_path(conn, :update, 2_147_483_647, %{title: "title"}))

      assert html_response(conn, 404) =~ "Not Found"
    end

    test "/update without being logged in redirects", %{conn: conn} do
      {_, links} = create_link()
      link = links |> hd()
      conn = put(conn, Routes.link_path(conn, :update, link.id, %{title: "title"}))
      assert html_response(conn, 302)
    end
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

    Repo.insert_all(Link, [link], returning: [:id])
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
