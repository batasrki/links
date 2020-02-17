defmodule LinksWeb.AuthHelper do
  alias Plug.Conn
  alias Links.Accounts.Sessions

  def logged_in?(conn) do
    with session_id when not is_nil(session_id) <- Conn.get_session(conn, :session_id),
         session when not is_nil(session) <- Sessions.get_by_id(session_id) do
      true
    else
      nil -> false
    end
  end
end
