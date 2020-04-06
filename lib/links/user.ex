defmodule Links.User do
  use Ecto.Schema
  import Ecto.Query
  require Logger

  schema "users" do
    field(:username, :string)
    field(:email, :string)
    has_many(:links, Links.Link)
    timestamps(type: :utc_datetime)
  end

  ####### QUERIES ##########
  def all() do
    __MODULE__
    |> select([:id, :email, :username, :inserted_at])
    |> Links.Repo.all()
  end

  ##########################
end
