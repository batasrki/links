defmodule Links.TestPostgresImporter do
  use ExUnit.Case
  import Exredis.Api
  alias Links.{PostgresImporter, RedisRepo}

  setup do
    case Enum.find(Process.registered(), fn name -> name == :particle_transporter end) do
      nil ->
        :ok

      _ ->
        Process.unregister(:particle_transporter)
        :ok
    end
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
    {:ok, repo} = RedisRepo.start_link(:particle_transporter, "redis://127.0.0.1:6379/10")
    {:ok, test_timestamp} = DateTime.from_naive(~N[2018-10-20 19:48:06.000000], "Etc/UTC")
    {:ok, test1_timestamp} = DateTime.from_naive(~N[2018-10-22 19:48:06.000000], "Etc/UTC")

    key = "test:set"
    repo |> zadd(key, DateTime.to_unix(test_timestamp), "{\"val\": \"test\"}")
    repo |> zadd(key, DateTime.to_unix(test1_timestamp), "{\"val\": \"test 1\"}")

    {:ok, timestamp} = DateTime.from_naive(~N[2018-10-13 19:48:06.000000], "Etc/UTC")

    assert PostgresImporter.fetch_redis_records(key, timestamp) == [
             %{"val" => "test"},
             %{"val" => "test 1"}
           ]

    repo |> del(key)
  end

  test "fetch all Redis records using nil timestamp" do
    {:ok, repo} = RedisRepo.start_link(:particle_transporter, "redis://127.0.0.1:6379/10")
    {:ok, test_timestamp} = DateTime.from_naive(~N[2018-10-20 19:48:06.000000], "Etc/UTC")
    {:ok, test1_timestamp} = DateTime.from_naive(~N[2018-10-22 19:48:06.000000], "Etc/UTC")

    key = "test:set"
    repo |> zadd(key, DateTime.to_unix(test_timestamp), "{\"val\": \"test\"}")
    repo |> zadd(key, DateTime.to_unix(test1_timestamp), "{\"val\": \"test 1\"}")

    assert PostgresImporter.fetch_redis_records(key, nil) == [
             %{"val" => "test"},
             %{"val" => "test 1"}
           ]

    repo |> del(key)
  end
end
