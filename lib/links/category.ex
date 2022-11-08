defmodule Links.Category do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  require Logger

  schema "categories" do
    field :name, :string
    many_to_many(:links, Links.Link, join_through: "category_links")

    timestamps()
  end

  def all do
    Links.Repo.all from c in Links.Category
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
