defmodule Links.TestRepo do
  use ExUnit.Case
  alias Links.{Repo, Link, User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    seed_tables()

    on_exit(fn ->
      Repo.delete_all(Link)
      Repo.delete_all(User)
    end)
  end

  test "find by URL" do
    result = Link.find_by_url("http://localhost:8081/test/404.html")
    assert "http://localhost:8081/test/404.html" == result.url
  end

  test "find by ID" do
    result = Link.find_by_url("http://localhost:8081/test/howto.html")
    assert result == Link.find_by_id(result.id)
  end

  test "updating a link URL works" do
    link = Link.find_by_url("http://localhost:8081/test/howto.html")

    update_params = %{
      url: "http://localhost:8081/test/howto_1.html",
      client: "test_client"
    }

    {:ok, result} = Link.update(link, update_params)
    assert "http://localhost:8081/test/howto_1.html" == result.url
  end

  test "updating a link URL with garbage doesn't work" do
    link = Link.find_by_url("http://localhost:8081/test/howto.html")

    update_params = %{
      url: "garbage",
      client: "test_client"
    }

    {:error, result} = Link.update(link, update_params)
    assert {:url, {"has invalid format", [validation: :format]}} in result.errors
  end

  test "updating a link URL with an empty value doesn't work" do
    link = Link.find_by_url("http://localhost:8081/test/howto.html")

    update_params = %{
      url: "",
      client: "test_client"
    }

    {:error, result} = Link.update(link, update_params)
    assert {:url, {"can't be blank", [validation: :required]}} in result.errors
  end

  test "updating a link title works" do
    link = Link.find_by_url("http://localhost:8081/test/howto.html")

    update_params = %{
      title: "Updated title",
      client: "test_client"
    }

    {:ok, result} = Link.update(link, update_params)
    assert "Updated title" == result.title
  end

  test "updating a link title with an empty value doesn't work" do
    link = Link.find_by_url("http://localhost:8081/test/howto.html")

    update_params = %{
      title: "",
      client: "test_client"
    }

    {:error, result} = Link.update(link, update_params)
    assert {:title, {"can't be blank", [validation: :required]}} in result.errors
  end

  test "creating a link works" do
    user = Repo.one!(User)

    params = %{
      url: "http://localhost:8081/test/creation.html",
      client: "test client",
      title: "http://localhost:8081/test/creation.html",
      added_at: DateTime.utc_now() |> DateTime.truncate(:second),
      user_id: user.id
    }

    {:ok, result} = Link.create(params)
    assert params.url == result.url
  end

  test "creating a link with a bad URL doesn't work" do
    params = %{
      url: "garbage",
      client: "test client",
      title: "garbage",
      added_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }

    {:error, result} = Link.create(params)
    assert {:url, {"has invalid format", [validation: :format]}} in result.errors
  end

  test "creating a link with an empty URL doesn't work" do
    params = %{
      url: "",
      client: "test client",
      title: "",
      added_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }

    {:error, result} = Link.create(params)
    assert {:url, {"can't be blank", [validation: :required]}} in result.errors
  end

  test "creating a link with a duplicate URL doesn't work" do
    user = Repo.one!(User)

    params = %{
      url: "http://localhost:8081/test/creation.html",
      title: "http://localhost:8081/test/creation.html",
      client: "test client",
      added_at: DateTime.utc_now() |> DateTime.truncate(:second),
      user_id: user.id
    }

    _valid = Link.create(params)

    {:error, invalid} = Link.create(params)

    assert {:url,
            {"has already been taken", [constraint: :unique, constraint_name: "links_url_index"]}} in invalid.errors
  end

  test "result limiting code works" do
    items = Link.list(%{}, %{per_page: 1, sort_direction: "asc"})
    assert 1 == Enum.count(items)
  end

  test "pagination code works" do
    link = Link.find_by_url("http://localhost:8081/test/howto.html")
    items = Link.list(%{}, %{per_page: 1, after: link.id, sort_direction: "asc"})

    fetched_link = items |> Enum.at(0)

    assert 1 == Enum.count(items)
    assert "http://localhost:8081/test/403.html" == fetched_link.url
  end

  defp seed_tables do
    user = Repo.insert!(%User{email: "test@example.com", username: "tester"})

    links = [
      %{
        url: "http://localhost:8081/test/howto.html",
        title: "How To Seed the Test DB",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client",
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
        user_id: user.id
      },
      %{
        url: "http://localhost:8081/test/403.html",
        title: "How To Seed the Test DB",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client",
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
        user_id: user.id
      },
      %{
        url: "http://localhost:8081/test/404.html",
        title: "This one 404s",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client",
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
        user_id: user.id
      },
      %{
        url: "http://localhost:8081/test/429.html",
        title: "This one hits a rate limit",
        state: "active",
        added_at: DateTime.utc_now() |> DateTime.truncate(:second),
        client: "test client",
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
        user_id: user.id
      }
    ]

    Links.Repo.insert_all(Links.Link, links)
  end
end
