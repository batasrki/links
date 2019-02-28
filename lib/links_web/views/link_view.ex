defmodule LinksWeb.LinkView do
  use LinksWeb, :view

  def archived?(link) do
    case link.archive do
      false -> ""
      true -> "border border-danger"
    end
  end
end
