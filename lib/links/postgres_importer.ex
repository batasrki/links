defmodule Links.PostgresImporter do
  alias __MODULE__

  def convert_timestamp(nil) do
    "-inf"
  end

  def convert_timestamp(timestamp) do
    DateTime.from_naive!(timestamp, "Etc/UTC") |> DateTime.to_unix()
  end

  def fetch_redis_records(key, from_timestamp) do
    tl(Links.RedisRepo.list_recent(key, convert_timestamp(from_timestamp)))
  end

  def persist_records(redis_records) do
    Links.Repo.batch_save!(redis_records)
  end

  def import(key, from_timestamp) do
    fetch_redis_records(key, from_timestamp)
    |> persist_records()
  end
end
