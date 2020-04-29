defmodule LinksWeb.LinkView do
  use LinksWeb, :view

  def empty_set?(links) do
    Enum.empty?(links)
  end

  def archived?(link) do
    case link.state == "archived" do
      true -> "border border-danger"
      false -> ""
    end
  end
end
