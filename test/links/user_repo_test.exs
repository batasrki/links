defmodule Links.TestUserRepo do
  use ExUnit.Case
  alias Links.{Repo, User}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    on_exit(fn ->
      Repo.delete_all(User)
    end)
  end

  test "all with no params gets all users" do
    Links.Accounts.User.create(create_params())
    user = User.all() |> hd()

    assert "tester@example.com", user.email
  end

  defp create_params(opts \\ %{}) do
    default_params = %{
      username: "tester",
      email: "tester@example.com"
    }

    Map.merge(default_params, opts)
  end
end
