defmodule Links.Repo.Migrations.CreateUsersTableForGhActions do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:users) do
      add(:email, :string, size: 100)
      add(:username, :string, size: 100)
      timestamps(type: :utc_datetime)
    end
  end
end
