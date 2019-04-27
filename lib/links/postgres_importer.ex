defmodule Links.PostgresImporter do
  require Logger

  def convert_timestamp(timestamp) do
    DateTime.from_naive!(timestamp, "Etc/UTC") |> DateTime.to_unix()
  end

  def fetch_redis_records(key, nil) do
    records = Links.RedisRepo.list_recent(key, "-inf")
    Logger.info("Fetching all Redis records as a clean import from key #{key}")
    records
  end

  def fetch_redis_records(key, most_recent_record) do
    records = Links.RedisRepo.list_recent(key, convert_timestamp(most_recent_record.added_at))

    Logger.info(
      "Fetching records with #{convert_timestamp(most_recent_record.added_at)} under #{key} key."
    )

    Logger.info("Found #{Enum.count(records)} records.")
    records
  end

  def persist_records(redis_records, nil) do
    redis_records
    |> Links.Repo.batch_save!()
  end

  def persist_records(redis_records, most_recent_record) do
    redis_records
    |> Stream.filter(fn record -> record["url"] == most_recent_record.url end)
    |> Links.Repo.batch_save!()
  end

  def import(key, most_recent_record) do
    fetch_redis_records(key, most_recent_record)
    |> persist_records(most_recent_record)
  end
end
