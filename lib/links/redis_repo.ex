defmodule Links.RedisRepo do
  require Logger

  def start_link(name) do
    {:ok, client} = Exredis.start_link()
    true = Process.register(client, name)
    {:ok, client}
  end

  def list_recent(key, from_timestamp) do
    Process.whereis(:particle_transporter)
    |> Exredis.Api.zrangebyscore(key, from_timestamp, "+inf")
    |> Enum.map(fn item -> Poison.Parser.parse!(item) end)
  end
end
