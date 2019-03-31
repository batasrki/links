defmodule LinksWeb.LinkView do
  use LinksWeb, :view

  def archived?(link) do
    case link.archive do
      true -> "border border-danger"
      false -> ""
      nil -> ""
    end
  end
end
