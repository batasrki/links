defmodule Links.Repo.Migrations.AddUserIdAddedAtIndex do
  use Ecto.Migration

  def change do
    create(index("links", [:user_id, :added_at]))
  end
end
