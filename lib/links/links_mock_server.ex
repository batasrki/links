defmodule Links.LinksMockServer do
  use GenServer
  alias Links.MockController

  def init(args) do
    {:ok, args}
  end

  def start_link(_) do
    Plug.Cowboy.http(MockController, [], port: 8081)
  end
end
