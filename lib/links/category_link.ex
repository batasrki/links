defmodule Links.CategoryLink do
  use Ecto.Schema
  import Ecto.Changeset

  schema "category_links" do
    field :category_id, :integer
    field :link_id, :integer

    timestamps()
  end

  @doc false
  def changeset(category_link, attrs) do
    category_link
    |> cast(attrs, [:category_id, :link_id])
    |> validate_required([:category_id, :link_id])
  end
end
