defmodule Links.TestPostgresImporter do
  use ExUnit.Case
  import Exredis.Api
  alias Links.{PostgresImporter, Repo}

  @key "test:set"

  setup do
    on_exit(fn ->
      Process.whereis(:particle_transporter) |> del(@key)
      Moebius.Query.db(:links) |> Moebius.Query.delete() |> Moebius.Db.run()
    end)
  end

  test "convert a datetime record to a Unix timestamp" do
    {:ok, timestamp} = DateTime.from_naive(~N[2018-10-13 19:48:06.000000], "Etc/UTC")
    converted_timestamp = DateTime.to_unix(timestamp)
    assert PostgresImporter.convert_timestamp(timestamp) == converted_timestamp
  end

  test "iterate over Redis records using the timestamp" do
    {:ok, test_timestamp} = DateTime.from_naive(~N[2018-10-20 19:48:06.000000], "Etc/UTC")
    {:ok, test1_timestamp} = DateTime.from_naive(~N[2018-10-22 19:48:06.000000], "Etc/UTC")

    Process.whereis(:particle_transporter)
    |> zadd(@key, DateTime.to_unix(test_timestamp), "{\"val\": \"test\"}")

    Process.whereis(:particle_transporter)
    |> zadd(@key, DateTime.to_unix(test1_timestamp), "{\"val\": \"test 1\"}")

    {:ok, timestamp} = DateTime.from_naive(~N[2018-10-13 19:48:06.000000], "Etc/UTC")

    existing_record = %{added_at: timestamp}

    assert PostgresImporter.fetch_redis_records(@key, existing_record) == [
             %{"val" => "test"},
             %{"val" => "test 1"}
           ]
  end

  test "fetch all Redis records using nil timestamp" do
    {:ok, test_timestamp} = DateTime.from_naive(~N[2018-10-20 19:48:06.000000], "Etc/UTC")
    {:ok, test1_timestamp} = DateTime.from_naive(~N[2018-10-22 19:48:06.000000], "Etc/UTC")

    Process.whereis(:particle_transporter)
    |> zadd(@key, DateTime.to_unix(test_timestamp), "{\"val\": \"test\"}")

    Process.whereis(:particle_transporter)
    |> zadd(@key, DateTime.to_unix(test1_timestamp), "{\"val\": \"test 1\"}")

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

    PostgresImporter.persist_records([redis_record], nil)

    assert Enum.count(Repo.list(%{sort_direction: :asc})) == 1
  end

  test "it works end to end with nil timestamp" do
    save_to_redis()

    PostgresImporter.import(@key, nil)
    assert Enum.count(Repo.list(%{sort_direction: :asc})) == 2
  end

  test "it works end to end with non-nil timestamp" do
    save_to_redis()

    Repo.batch_save!([
      %{
        "url" => "https://example.org/",
        "client" => "test_client",
        "title" => "Example link",
        "archive" => false,
        "timestamp" => 1_540_151_286
      }
    ])

    existing_record = %{
      added_at: ~N[2018-10-21 19:48:06.000000],
      url: "https://testing.example.org"
    }

    PostgresImporter.import(@key, existing_record)
    record = hd(Repo.by_last_added_at(%{sort_direction: :desc, per_page: 1, page: 1}))
    assert "https://test.example.org", record.url
  end

  defp save_to_redis() do
    {:ok, test_timestamp} = DateTime.from_naive(~N[2018-10-20 19:48:06.000000], "Etc/UTC")
    {:ok, test1_timestamp} = DateTime.from_naive(~N[2018-10-22 19:48:06.000000], "Etc/UTC")

    Process.whereis(:particle_transporter)
    |> zadd(
      @key,
      DateTime.to_unix(test_timestamp),
      "{\"url\": \"https://example.org\", \"client\": \"heimdall\", \"title\": \"Example link\", \"archive\": false, \"timestamp\": 1535236965}"
    )

    Process.whereis(:particle_transporter)
    |> zadd(
      @key,
      DateTime.to_unix(test1_timestamp),
      "{\"url\": \"https://test.example.org\", \"client\": \"heimdall\", \"title\": \"Example link\", \"archive\": false, \"timestamp\": 1535236966}"
    )
  end
end
