defmodule Links.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  require Logger

  alias Links.Accounts.{LoginRequest, Session}

  schema "users" do
    field(:username, :string)
    field(:email, :string)
    timestamps(type: :utc_datetime)
    has_one(:login_request, LoginRequest)
    has_many(:sessions, Session)
  end

  ####### QUERIES ############
  def get_by_email(email) do
    Links.Repo.get_by(__MODULE__, email: email)
  end

  ############################

  ####### MUTATIONS ##########
  def create(params) do
    changeset = __MODULE__.create_changeset(%Links.User{}, params)
    Links.Repo.insert(changeset)
  end

  def create_for_session(params) do
    changeset = __MODULE__.create_changeset(%Links.Accounts.User{}, params)
    Links.Repo.insert(changeset)
  end

  def create_changeset(user, params) do
    user
    |> cast(params, [:username, :email])
    |> validate_required([:username, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  ############################
end
