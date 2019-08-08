defmodule Links.TestLinkLocationValidator do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Links.{Repo, LinkLocationValidator}

  setup do
    seed_table()

    on_exit(fn ->
      Moebius.Query.db(:links) |> Moebius.Query.delete() |> Moebius.Db.run()
    end)
  end

  test "getting a 301 updates the link URL" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/301.html"}
    record = Repo.find_by_url(url_to_fetch["url"]) |> Enum.at(0)

    assert url_to_fetch["url"] == record.url
    LinkLocationValidator.validate(record)

    updated_record = Repo.find_by_id(record.id) |> Enum.at(0)
    assert updated_record.url == "http://localhost:8081/test/howto.html"
  end

  test "getting a 302 updates the link URL" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/302.html"}
    record = Repo.find_by_url(url_to_fetch["url"]) |> Enum.at(0)

    assert url_to_fetch["url"] == record.url
    LinkLocationValidator.validate(record)

    updated_record = Repo.find_by_id(record.id) |> Enum.at(0)
    assert updated_record.url == "http://localhost:8081/test/howto.html"
  end

  test "getting a 404 while archives the link" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/404.html"}
    record = Repo.find_by_url(url_to_fetch["url"]) |> Enum.at(0)

    assert url_to_fetch["url"] == record.url
    LinkLocationValidator.validate(record)

    updated_record = Repo.find_by_id(record.id) |> Enum.at(0)
    assert updated_record.archive
  end

  test "getting an error logs it and moves on" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/500.html"}
    record = Repo.find_by_url(url_to_fetch["url"]) |> Enum.at(0)

    assert url_to_fetch["url"] == record.url
    assert capture_log(fn -> LinkLocationValidator.validate(record, 0) end)
  end

  defp seed_table do
    links = [
      %{
        "url" => "http://localhost:8081/test/404.html",
        "title" => "This link 404s",
        "archive" => false,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      },
      %{
        "url" => "http://localhost:8081/test/301.html",
        "title" => "This link 301s",
        "archive" => false,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      },
      %{
        "url" => "http://localhost:8081/test/302.html",
        "title" => "This link 302s",
        "archive" => false,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      },
      %{
        "url" => "http://localhost:8081/test/500.html",
        "title" => "This link 500s",
        "archive" => false,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      }
    ]

    Links.Repo.batch_save!(links)
  end
end
