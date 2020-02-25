defmodule Links.TestLinkReader do
  use ExUnit.Case
  alias Links.{LinkReader, Link, Repo}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

    on_exit(fn ->
      Repo.delete_all(Link)
    end)
  end

  test "#by_id_for_editing returns nil if the record isn't found" do
    assert {:error, :not_found} == LinkReader.by_id_for_editing("1")
  end
end
