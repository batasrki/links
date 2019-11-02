defmodule Links.User do
  use Ecto.Repo,
    otp_app: :links,
    adapter: Ecto.Adapters.Postgres

  require Logger
  import Pbkdf2, only: [hash_pwd_salt: 1, verify_pass: 2]

  defstruct [:email, :username, :password, :hashed_password]

  def create(params) do
    prepared_item = list_from_map(params)
    prepared_item = prepared_item ++ [inserted_at: DateTime.utc_now()]

    # query =
    #   Query.db(@table_name)
    #   |> Query.insert(prepared_item)

    # query |> Db.run()
  end

  def update(id, params) do
    prepared_item = list_from_map(params)

    # query =
    #   Query.db(@table_name)
    #   |> Query.filter(id: id)
    #   |> Query.update(prepared_item)

    # query |> Db.run()
  end

  def list_from_map(item) do
    item =
      cond do
        item["password"] != nil ->
          item = Map.put(item, "hashed_password", hash_password(item["password"]))
          Map.delete(item, "password")

        item["password"] == nil ->
          item
      end

    initial_list = for {k, v} <- item, into: [], do: {String.to_existing_atom(k), v}
    initial_list ++ [updated_at: DateTime.utc_now()]
  end

  def hash_password(plaintext) do
    hash_pwd_salt(plaintext)
  end

  def verify_password(passwd, hash) do
    verify_pass(passwd, hash)
  end
end
