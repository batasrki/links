defmodule LinksWeb.LinkControllerTest do
  use LinksWeb.ConnCase

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Links.Repo)

    on_exit(fn ->
      Links.Repo.delete_all(Links.Link)
    end)
  end

  test "/edit", %{conn: conn} do
    {_, links} = create_link()
    link = links |> hd()
    conn = get(conn, "links/#{link.id}/edit")
    assert html_response(conn, 200) =~ "How To Seed the Test DB"
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
end
