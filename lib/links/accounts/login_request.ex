defmodule Links.Accounts.LoginRequest do
  use Ecto.Schema
  alias Links.Accounts.User

  schema "login_requests" do
    timestamps(type: :utc_datetime)
    belongs_to(:user, User)
  end
end
