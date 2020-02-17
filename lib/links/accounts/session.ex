defmodule Links.Accounts.Session do
  use Ecto.Schema

  alias Links.Accounts.User

  schema "sessions" do
    timestamps(type: :utc_datetime)
    belongs_to(:user, User)
  end
end
