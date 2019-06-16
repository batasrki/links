defmodule LinksWeb.ApiController do
  use LinksWeb, :controller
  alias Links.LinkReader

  def index(conn, _params) do
    json(conn, LinkReader.to_list())
  end
end
