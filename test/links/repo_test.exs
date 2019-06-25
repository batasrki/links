defmodule Links.TestRepo do
  use ExUnit.Case
  alias Links.Repo

  setup do
    seed_table()

    on_exit(fn ->
      Moebius.Query.db(:links) |> Moebius.Query.delete() |> Moebius.Db.run()
    end)
  end

  test "find_by_url" do
    result = Repo.find_by_url("http://localhost:8081/test/404.html")
    assert 1 <= Enum.count(result)
  end

  test "find by url can return more than one" do
    result = Repo.find_by_url("http://localhost:8081/test/404.html")
    assert 1 < Enum.count(result)
  end

  test "find by ID" do
    result = Repo.find_by_url("http://localhost:8081/test/howto.html") |> Enum.at(0)
    assert result == Repo.find_by_id(result.id) |> Enum.at(0)
  end

  test "updating a link URL works" do
    link = Repo.find_by_url("http://localhost:8081/test/howto.html") |> Enum.at(0)

    update_params = %{
      "url" => "http://localhost:8081/test/howto_1.html",
      "client" => "test_client"
    }

    case Repo.update(link.id, update_params) do
      {:ok, record} ->
        assert "http://localhost:8081/test/howto_1.html" == record.url

      {:error, message} ->
        IO.puts(message)
    end
  end

  test "updating a link title works" do
    link = Repo.find_by_url("http://localhost:8081/test/howto.html") |> Enum.at(0)

    update_params = %{
      "title" => "Updated title",
      "client" => "test_client"
    }

    case Repo.update(link.id, update_params) do
      {:ok, record} ->
        assert "Updated title" == record.title

      {:error, message} ->
        IO.puts(message)
    end
  end

  test "creating a link works" do
    create_params = %{
      "url" => "http://localhost:8081/test/creation.html",
      "client" => "test client",
      "added_at" => NaiveDateTime.utc_now()
    }

    case Repo.create(create_params) do
      {:ok, record} ->
        assert Regex.run(~r{.*creation.*}, record.url)

      {:error, message} ->
        IO.puts(message)
    end
  end

  defp seed_table do
    links = [
      %{
        "url" => "http://localhost:8081/test/howto.html",
        "title" => "How To Seed the Test DB",
        "archive" => false,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      },
      %{
        "url" => "http://localhost:8081/test/404.html",
        "title" => "How To Seed the Test DB",
        "archive" => true,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      },
      %{
        "url" => "http://localhost:8081/test/404.html",
        "title" => "This one 404s",
        "archive" => false,
        "added_at" => NaiveDateTime.utc_now(),
        "client" => "test client"
      }
    ]

    Links.Repo.batch_save!(links)
  end
end
