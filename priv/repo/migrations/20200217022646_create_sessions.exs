defmodule Links.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      timestamps(type: :utc_datetime)
    end

    create(index(:sessions, [:user_id]))
  end
end
