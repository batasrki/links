defmodule Links.Accounts.UserTest do
  use ExUnit.Case
  alias Links.{Repo, Accounts.User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    on_exit(fn ->
      Repo.delete_all(User)
    end)
  end

  test "creating a user works" do
    {:ok, record} = User.create(create_params())
    assert "tester" == record.username
    assert "tester@example.com" == record.email
  end

  test "creating a user with a bad e-mail doesn't work" do
    {:error, result} = User.create(create_params(%{email: "baademail"}))
    assert {:email, {"has invalid format", [validation: :format]}} in result.errors
  end

  test "creating a user without a username doesn't work" do
    {:error, result} = User.create(create_params(%{username: nil}))
    assert {:username, {"can't be blank", [validation: :required]}} in result.errors
  end

  test "creating a user without an email doesn't work" do
    {:error, result} = User.create(create_params(%{email: nil}))
    assert {:email, {"can't be blank", [validation: :required]}} in result.errors
  end

  test "creating a user with an email that already exists fails" do
    User.create(create_params())
    {:error, result} = User.create(create_params())

    assert {:email,
            {"has already been taken",
             [constraint: :unique, constraint_name: "users_email_index"]}} in result.errors
  end

  defp create_params(opts \\ %{}) do
    default_params = %{
      username: "tester",
      email: "tester@example.com"
    }

    Map.merge(default_params, opts)
  end
end
