defmodule Links.TestLinkMutator do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Links.{Repo, Link, LinkMutator}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    seed_table()

    on_exit(fn ->
      Repo.delete_all(Link)
    end)
  end

  test "#create makes a new record" do
    {:ok, result} = LinkMutator.create(create_params())
    assert "test client" == result.client
  end

  test "#create logs when there's an error" do
    assert capture_log(fn -> LinkMutator.create(create_with_invalid_params()) end)
  end

  test "#update returns a successful update" do
    link = Link.find_by_url("http://localhost:8081/test/404.html")

    {:ok, result} = LinkMutator.update(link, update_params())
    assert "http://localhost:8081/test/howto.html" == result.url
  end

  test "#update returns an error tuple if there are errors" do
    link = Link.find_by_url("http://localhost:8081/test/404.html")
    assert {:error, _} = LinkMutator.update(link, update_with_invalid_params())
  end

  defp create_with_invalid_params() do
    %{
      "client" => "test client"
    }
  end

  defp create_params() do
    %{
      "url" => "http://localhost:8081/test/howto.html",
      "client" => "test client"
    }
  end

  defp update_params() do
    %{
      "url" => "http://localhost:8081/test/howto.html",
      "client" => "test client",
      "title" => "How To Mock a Server"
    }
  end

  defp update_with_invalid_params() do
    %{
      "url" => "garbage",
      "client" => "test client",
      "title" => "How To Mock a Server"
    }
  end

  defp seed_table do
    links = [
      %{
        url: "http://localhost:8081/test/404.html",
        title: "This link 404s",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "not found client"
      }
    ]

    Repo.insert_all(Links.Link, links)
  end
end
