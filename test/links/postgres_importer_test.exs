defmodule Links.TestPostgresImporter do
  use ExUnit.Case
  import Exredis.Api
  alias Links.{PostgresImporter, RedisRepo, Repo}

  @repo nil
  @key "test:set"

  setup_all do
    case Enum.find(Process.registered(), fn name -> name == :particle_transporter end) do
      nil ->
        :ok

      _ ->
        IO.puts("unregistering #{IO.inspect(Process.whereis(:particle_transporter))}")
        Process.unregister(:particle_transporter)
        :ok
    end

    {:ok, pid} = RedisRepo.start_link(:particle_transporter, "redis://127.0.0.1:6379/10")
    @repo = pid
    :ok
  end

  setup do
    on_exit(fn ->
      @repo |> del(@key)
      Moebius.Query.db(:links) |> Moebius.Query.delete() |> Moebius.Db.run()
    end)
  end

  test "convert null timestamp to '-inf'" do
    timestamp = nil
    assert PostgresImporter.convert_timestamp(timestamp) == "-inf"
  end

  test "convert a datetime record to a Unix timestamp" do
    {:ok, timestamp} = DateTime.from_naive(~N[2018-10-13 19:48:06.000000], "Etc/UTC")
    converted_timestamp = DateTime.to_unix(timestamp)
    assert PostgresImporter.convert_timestamp(timestamp) == converted_timestamp
  end

  test "iterate over Redis records using the timestamp" do
    {:ok, test_timestamp} = DateTime.from_naive(~N[2018-10-20 19:48:06.000000], "Etc/UTC")
    {:ok, test1_timestamp} = DateTime.from_naive(~N[2018-10-22 19:48:06.000000], "Etc/UTC")

    @repo |> zadd(@key, DateTime.to_unix(test_timestamp), "{\"val\": \"test\"}")
    @repo |> zadd(@key, DateTime.to_unix(test1_timestamp), "{\"val\": \"test 1\"}")

    {:ok, timestamp} = DateTime.from_naive(~N[2018-10-13 19:48:06.000000], "Etc/UTC")

    assert PostgresImporter.fetch_redis_records(@key, timestamp) == [
             %{"val" => "test"},
             %{"val" => "test 1"}
           ]
  end

  test "fetch all Redis records using nil timestamp" do
    {:ok, test_timestamp} = DateTime.from_naive(~N[2018-10-20 19:48:06.000000], "Etc/UTC")
    {:ok, test1_timestamp} = DateTime.from_naive(~N[2018-10-22 19:48:06.000000], "Etc/UTC")

    @repo |> zadd(@key, DateTime.to_unix(test_timestamp), "{\"val\": \"test\"}")
    @repo |> zadd(@key, DateTime.to_unix(test1_timestamp), "{\"val\": \"test 1\"}")

    assert PostgresImporter.fetch_redis_records(@key, nil) == [
             %{"val" => "test"},
             %{"val" => "test 1"}
           ]
  end

  test "save fetched Redis record to the database" do
    redis_record = %{
      "url" => "https://example.org",
      "client" => "heimdall",
      "title" => "Example link",
      "archive" => false,
      "timestamp" => 1_535_236_965
    }

    PostgresImporter.persist_records([redis_record])

    assert Enum.count(Repo.list()) == 1
  end

  test "it works end to end with nil timestamp" do
    {:ok, test_timestamp} = DateTime.from_naive(~N[2018-10-20 19:48:06.000000], "Etc/UTC")
    {:ok, test1_timestamp} = DateTime.from_naive(~N[2018-10-22 19:48:06.000000], "Etc/UTC")

    @repo
    |> zadd(
      @key,
      DateTime.to_unix(test_timestamp),
      "{\"url\": \"https://example.org\", \"client\": \"heimdall\", \"title\": \"Example link\", \"archive\": false, \"timestamp\": 1535236965}"
    )

    @repo
    |> zadd(
      @key,
      DateTime.to_unix(test1_timestamp),
      "{\"url\": \"https://example.org\", \"client\": \"heimdall\", \"title\": \"Example link\", \"archive\": false, \"timestamp\": 1535236966}"
    )

    PostgresImporter.import(@key, nil)
    assert Enum.count(Repo.list()) == 2
  end
end
