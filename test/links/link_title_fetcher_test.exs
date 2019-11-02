defmodule Links.TestLinkTitleFetcher do
  use ExUnit.Case
  alias Links.{Repo, LinkTitleFetcher, Link}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    seed_table()

    on_exit(fn ->
      Repo.delete_all(Link)
    end)
  end

  test "fetching a title updates the saved record" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/howto.html"}
    record = Link.find_by_url(url_to_fetch["url"])

    assert url_to_fetch["url"] == record.url
    LinkTitleFetcher.get_title(url_to_fetch)

    updated_record = Link.find_by_id(record.id)
    assert updated_record.url != updated_record.title
  end

  test "fetching a weirder title updates the saved record" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/howto1.html"}
    record = Link.find_by_url(url_to_fetch["url"])

    assert url_to_fetch["url"] == record.url
    LinkTitleFetcher.get_title(url_to_fetch)

    updated_record = Link.find_by_id(record.id)
    assert updated_record.url != updated_record.title
  end

  test "getting a 404 while fetching the title archives the link" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/404.html"}
    record = Link.find_by_url(url_to_fetch["url"])

    assert url_to_fetch["url"] == record.url
    LinkTitleFetcher.get_title(url_to_fetch)

    updated_record = Link.find_by_id(record.id)
    assert "archived" == updated_record.state
  end

  defp seed_table do
    links = [
      %{
        url: "http://localhost:8081/test/howto.html",
        title: "http://localhost:8081/test/howto.html",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client"
      },
      %{
        url: "http://localhost:8081/test/howto1.html",
        title: "http://localhost:8081/test/howto1.html",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client"
      },
      %{
        url: "http://localhost:8081/test/404.html",
        title: "This link 404s",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client"
      }
    ]

    Repo.insert_all(Links.Link, links)
  end
end
