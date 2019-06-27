defmodule LinksWeb.UpdatesChannel do
  use Phoenix.Channel

  @impl Phoenix.Channel
  def join("updates:*", _message, socket) do
    {:ok, socket}
  end

  @impl Phoenix.Channel
  def handle_in("incoming", payload, socket) do
    broadcast!(socket, "incoming", payload)
    {:noreply, socket}
  end
end
