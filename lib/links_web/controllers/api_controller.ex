defmodule LinksWeb.ApiController do
  use LinksWeb, :controller
  alias ParttransEngine.LinkDisplayer

  def index(conn, _params) do
    json(conn, LinkDisplayer.to_list())
  end
end
