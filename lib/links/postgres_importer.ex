defmodule Links.PostgresImporter do
  def convert_timestamp(nil) do
    "-inf"
  end

  def convert_timestamp(timestamp) do
    DateTime.to_unix(timestamp)
  end

  def fetch_redis_records(key, from_timestamp) do
    Links.RedisRepo.list_recent(key, convert_timestamp(from_timestamp))
  end
end
