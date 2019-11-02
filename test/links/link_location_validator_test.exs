defmodule Links.TestLinkLocationValidator do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Links.{Repo, LinkLocationValidator, Link}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    seed_table()

    on_exit(fn ->
      Repo.delete_all(Link)
    end)
  end

  test "getting a 301 updates the link URL" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/301.html"}
    record = Link.find_by_url(url_to_fetch["url"])

    assert url_to_fetch["url"] == record.url
    LinkLocationValidator.validate(record)

    updated_record = Link.find_by_id(record.id)
    assert updated_record.url == "http://localhost:8081/test/howto.html"
  end

  test "getting a 302 updates the link URL" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/302.html"}
    record = Link.find_by_url(url_to_fetch["url"])

    assert url_to_fetch["url"] == record.url
    LinkLocationValidator.validate(record)

    updated_record = Link.find_by_id(record.id)
    assert updated_record.url == "http://localhost:8081/test/howto.html"
  end

  test "getting a 404 while archives the link" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/404.html"}
    record = Link.find_by_url(url_to_fetch["url"])

    assert url_to_fetch["url"] == record.url
    LinkLocationValidator.validate(record)

    updated_record = Link.find_by_id(record.id)
    assert "archived" == updated_record.state
  end

  test "getting an error logs it and moves on" do
    url_to_fetch = %{"url" => "http://localhost:8081/test/500.html"}
    record = Link.find_by_url(url_to_fetch["url"])

    assert url_to_fetch["url"] == record.url
    assert capture_log(fn -> LinkLocationValidator.validate(record, 0) end)
  end

  defp seed_table do
    links = [
      %{
        url: "http://localhost:8081/test/404.html",
        title: "This link 404s",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client"
      },
      %{
        url: "http://localhost:8081/test/301.html",
        title: "This link 301s",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client"
      },
      %{
        url: "http://localhost:8081/test/302.html",
        title: "This link 302s",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client"
      },
      %{
        url: "http://localhost:8081/test/500.html",
        title: "This link 500s",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client"
      }
    ]

    Links.Repo.insert_all(Link, links)
  end
end
