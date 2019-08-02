defmodule Links.TestLinkTitleFetcher do
  use ExUnit.Case
  alias Links.{Repo, LinkTitleFetcher}

  setup do
    seed_table()

    on_exit(fn ->
      Moebius.Query.db(:links) |> Moebius.Query.delete() |> Moebius.Db.run()
    end)
  end

  test "fetching a title updates the saved record" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/howto.html"}
    record = Repo.find_by_url(url_to_fetch["url"]) |> Enum.at(0)

    assert url_to_fetch["url"] == record.url
    LinkTitleFetcher.get_title(url_to_fetch)

    updated_record = Repo.find_by_id(record.id) |> Enum.at(0)
    assert updated_record.url != updated_record.title
  end

  test "fetching a weirder title updates the saved record" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/howto1.html"}
    record = Repo.find_by_url(url_to_fetch["url"]) |> Enum.at(0)

    assert url_to_fetch["url"] == record.url
    LinkTitleFetcher.get_title(url_to_fetch)

    updated_record = Repo.find_by_id(record.id) |> Enum.at(0)
    assert updated_record.url != updated_record.title
  end

  test "getting a 404 while fetching the title archives the link" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/404.html"}
    record = Repo.find_by_url(url_to_fetch["url"]) |> Enum.at(0)

    assert url_to_fetch["url"] == record.url
    LinkTitleFetcher.get_title(url_to_fetch)

    updated_record = Repo.find_by_id(record.id) |> Enum.at(0)
    assert updated_record.archive
  end

  defp seed_table do
    links = [
      %{
        "url" => "http://localhost:8081/test/howto.html",
        "title" => "http://localhost:8081/test/howto.html",
        "archive" => false,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      },
      %{
        "url" => "http://localhost:8081/test/howto1.html",
        "title" => "http://localhost:8081/test/howto1.html",
        "archive" => false,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      },
      %{
        "url" => "http://localhost:8081/test/404.html",
        "title" => "This link 404s",
        "archive" => false,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      }
    ]

    Links.Repo.batch_save!(links)
  end
end
