defmodule LinksWeb.LinkView do
  use LinksWeb, :view

  def archived?(link) do
    case link.state == "archived" do
      true -> "border border-danger"
      false -> ""
    end
  end
end
