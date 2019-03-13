defmodule Links.RedisRepo do
  require Logger

  def start_link(name, uri) do
    client = Exredis.start_using_connection_string(uri)
    true = Process.register(client, name)
    {:ok, client}
  end

  def list_recent(key, from_timestamp) do
    Process.whereis(:particle_transporter)
    |> Exredis.Api.zrangebyscore(key, from_timestamp, "+inf")
    |> Enum.map(fn item -> Poison.Parser.parse!(item) end)
  end

  def list(per_page, 1) do
    Logger.info("Per page: #{inspect(per_page)}")
    from_store(0, per_page - 1)
  end

  def list(per_page, page) do
    start_index = (page - 1) * per_page
    end_index = start_index + (per_page - 1)
    Logger.info("start_index: #{start_index}; end_index: #{end_index}")

    cond do
      end_index > max_count() ->
        from_store(start_index, max_count())

      true ->
        from_store(start_index, end_index)
    end
  end

  defp from_store(start_index, end_index) do
    Process.whereis(:particle_transporter)
    |> Exredis.Api.zrange("posted:urls", start_index, end_index)
    |> Enum.map(fn item -> Poison.Parser.parse!(item) end)
  end

  defp max_count() do
    Process.whereis(:particle_transporter)
    |> Exredis.Api.zcount("posted:urls", "-inf", "+inf")
    |> String.to_integer()
  end
end
