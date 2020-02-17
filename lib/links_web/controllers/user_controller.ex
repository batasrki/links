defmodule LinksWeb.UserController do
  require Logger
  use LinksWeb, :controller

  def index(conn, _params) do
    users = Links.User.all()
    render(conn, "index.html", users: users)
  end
end
