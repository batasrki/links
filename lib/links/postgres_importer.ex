defmodule Links.PostgresImporter do
  require Logger

  def convert_timestamp(nil) do
    "-inf"
  end

  def convert_timestamp(timestamp) do
    DateTime.from_naive!(timestamp, "Etc/UTC") |> DateTime.to_unix()
  end

  def fetch_redis_records(key, from_timestamp) do
    records = Links.RedisRepo.list_recent(key, convert_timestamp(from_timestamp))
    Logger.info("Fetching records with #{convert_timestamp(from_timestamp)} under #{key} key.")
    Logger.info("Found #{Enum.count(records)} records.")
    records
  end

  def persist_records(redis_records) do
    redis_records
    |> Stream.take_while(fn record -> Enum.empty?(Links.Repo.find_by_url(record["url"])) end)
    |> Links.Repo.batch_save!()
  end

  def import(key, from_timestamp) do
    fetch_redis_records(key, from_timestamp)
    |> persist_records()
  end
end
