defmodule Links.TestLinkMutator do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Links.{Repo, Link, LinkMutator, User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    seed_tables()

    on_exit(fn ->
      Repo.delete_all(Link)
      Repo.delete_all(User)
    end)
  end

  test "#create makes a new record" do
    user = Repo.one!(User)
    {:ok, result} = LinkMutator.create(create_params(%{"user_id" => user.id}))
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

  defp create_params(opts \\ %{}) do
    Map.merge(
      opts,
      %{
        "url" => "http://localhost:8081/test/howto.html",
        "client" => "test client"
      }
    )
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

  defp seed_tables do
    user = Repo.insert!(%User{email: "test@example.com", username: "tester"})

    links = [
      %{
        url: "http://localhost:8081/test/404.html",
        title: "This link 404s",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "not found client",
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
        user_id: user.id
      }
    ]

    Repo.insert_all(Links.Link, links)
  end
end
