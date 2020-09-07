defmodule LinksWeb.LinkControllerTest do
  use LinksWeb.ConnCase

  alias Links.{Link, Repo}

  setup %{conn: conn} do
    {session, user} = create_session()
    {:ok, conn: conn, session: session, user: user}
  end

  describe "index" do
    test "/index without being logged in, redirects", %{conn: conn} do
      conn = get(conn, Routes.link_path(conn, :index))
      assert html_response(conn, 302)
    end

    test "/index while logged in but no links, shows empty state", %{
      conn: conn,
      session: session,
      user: user
    } do
      conn =
        conn
        |> init_test_session(%{
          session_id: session.id,
          config_params: %{sort_direction: "asc", user_id: user.id}
        })
        |> put_req_header("content-type", "text/html")
        |> get(Routes.link_path(conn, :index))

      assert html_response(conn, 200) =~ "No links right now"
    end

    test "/index while logged in and having a saved link, shows the link", %{
      conn: conn,
      session: session,
      user: user
    } do
      {_, links} = create_link()
      link = links |> hd()

      conn =
        conn
        |> init_test_session(%{
          session_id: session.id,
          config_params: %{sort_direction: "asc", user_id: user.id}
        })
        |> put_req_header("content-type", "text/html")
        |> get(Routes.link_path(conn, :edit, link.id))

      assert html_response(conn, 200) =~ "How To Seed the Test DB"
    end
  end

  describe "create" do
    test "/create works when logged in", %{conn: conn, session: session, user: user} do
      create_params = %{
        url: "https://www.example.com",
        client: "test client"
      }

      conn =
        conn
        |> init_test_session(%{
          session_id: session.id,
          config_params: %{sort_direction: "asc", user_id: user.id}
        })
        |> put_req_header("content-type", "text/html")
        |> post(Routes.link_path(conn, :create), link: create_params)

      expected_redir_path = "/links?sort_direction=asc&user_id=#{user.id}"

      assert expected_redir_path == redirected_to(conn, 302)
      conn = get(recycle(conn), expected_redir_path)
      assert html_response(conn, 200) =~ "www.example.com"
    end

    test "/create without being logged in redirects", %{conn: conn} do
      conn = post(conn, Routes.link_path(conn, :create), link: %{title: "title"})
      assert html_response(conn, 302)
    end
  end

  describe "edit" do
    test "/edit", %{conn: conn, session: session} do
      {_, links} = create_link()
      link = links |> hd()

      conn =
        conn
        |> init_test_session(%{session_id: session.id})
        |> put_req_header("content-type", "text/html")
        |> get(Routes.link_path(conn, :edit, link.id))

      assert html_response(conn, 200) =~ "How To Seed the Test DB"
    end

    test "/edit to a non-existent link returns 404 page", %{conn: conn, session: session} do
      conn =
        conn
        |> init_test_session(%{session_id: session.id})
        |> put_req_header("content-type", "text/html")
        |> get(Routes.link_path(conn, :edit, 2_147_483_647))

      assert html_response(conn, 404) =~ "not found"
    end

    test "/edit without being logged in redirects", %{conn: conn} do
      {_, links} = create_link()
      link = links |> hd()
      conn = get(conn, Routes.link_path(conn, :edit, link.id))
      assert html_response(conn, 302)
    end
  end

  describe "update" do
    test "/update works when logged in", %{conn: conn, session: session, user: user} do
      {_, links} = create_link(%{user_id: user.id})
      link = links |> hd()

      update_params = %{
        title: "Updating the seed"
      }

      conn =
        conn
        |> init_test_session(%{
          session_id: session.id,
          config_params: %{sort_direction: "asc", user_id: user.id}
        })
        |> put_req_header("content-type", "text/html")
        |> put(Routes.link_path(conn, :update, link.id), link: update_params)

      expected_redir_path = "/links?sort_direction=asc&user_id=#{user.id}"

      assert expected_redir_path == redirected_to(conn, 302)
      conn = get(recycle(conn), expected_redir_path)
      assert html_response(conn, 200) =~ "Updating the seed"
    end

    test "/update to a non-existent link returns 404 page", %{
      conn: conn,
      session: session,
      user: user
    } do
      conn =
        conn
        |> init_test_session(%{
          session_id: session.id,
          config_params: %{sort_direction: "asc", user_id: user.id}
        })
        |> put_req_header("content-type", "text/html")
        |> put(Routes.link_path(conn, :update, 2_147_483_647), link: %{title: "title"})

      assert html_response(conn, 404) =~ "not found"
    end

    test "/update without being logged in redirects", %{conn: conn} do
      {_, links} = create_link()
      link = links |> hd()
      conn = put(conn, Routes.link_path(conn, :update, link.id), link: %{title: "title"})
      assert html_response(conn, 302)
    end
  end

  describe "delete" do
    test "/delete works when logged in", %{conn: conn, session: session, user: user} do
      {_, links} = create_link(%{user_id: user.id})
      link = links |> hd()

      conn =
        conn
        |> init_test_session(%{
          session_id: session.id,
          config_params: %{sort_direction: "asc", user_id: user.id}
        })
        |> put_req_header("content-type", "text/html")
        |> delete(Routes.link_path(conn, :delete, link.id), link: %{})

      expected_redir_path = "/links?sort_direction=asc&user_id=#{user.id}"

      assert expected_redir_path == redirected_to(conn, 302)
      conn = get(recycle(conn), expected_redir_path)
      assert html_response(conn, 200) =~ "border-danger"
    end

    test "/delete of a non-existent link returns 404 page", %{
      conn: conn,
      session: session,
      user: user
    } do
      conn =
        conn
        |> init_test_session(%{
          session_id: session.id,
          config_params: %{sort_direction: "asc", user_id: user.id}
        })
        |> put_req_header("content-type", "text/html")
        |> delete(Routes.link_path(conn, :delete, 2_147_483_647), link: %{})

      assert html_response(conn, 404) =~ "not found"
    end

    test "/delete without being logged in redirects", %{conn: conn} do
      {_, links} = create_link()
      link = links |> hd()
      conn = delete(conn, Routes.link_path(conn, :delete, link.id), link: %{})
      assert html_response(conn, 302)
    end
  end

  defp create_link(attrs \\ %{}) do
    link = %{
      url: "http://localhost:8081/test/howto.html",
      title: "How To Seed the Test DB",
      state: "active",
      added_at: DateTime.utc_now() |> DateTime.truncate(:second),
      client: "test client",
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }

    link = Map.merge(link, attrs)

    Repo.insert_all(Link, [link], returning: [:id])
  end

  defp create_session() do
    {:ok, user} =
      Links.Accounts.User.create_for_session(%{
        email: "test@example.com",
        username: "tester"
      })

    {:ok, session} = Ecto.build_assoc(user, :sessions) |> Links.Repo.insert()
    {session, user}
  end
end
