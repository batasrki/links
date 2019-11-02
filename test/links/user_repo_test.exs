defmodule Links.TestUserRepo do
  use ExUnit.Case
  alias Links.User

  setup do
    on_exit(fn ->
      nil
      # Moebius.Query.db(:links) |> Moebius.Query.delete() |> Moebius.Db.run()
      # Moebius.Query.db(:users) |> Moebius.Query.delete() |> Moebius.Db.run()
    end)
  end

  test "creating a user works" do
    create_params = %{
      "username" => "tester",
      "email" => "tester@example.com",
      "password" => "srkijevo"
    }

    case User.create(create_params) do
      {:ok, record} ->
        assert "tester" == record.username
        assert User.verify_password("srkijevo", record.hashed_password)

      {:error, message} ->
        assert nil == message
    end
  end
end
