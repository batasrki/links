defmodule Links.Repo.Migrations.CreateLinksTableForGhActions do
  use Ecto.Migration

  def up do
    execute("""
    CREATE TYPE link_states AS ENUM('active', 'archived', 'unreachable')
    """)

    create_if_not_exists table(:links) do
      add(:title, :string, size: 100)
      add(:url, :string, size: 100)
      add(:client, :string, size: 50)
      add(:added_at, :"timestamp with time zone")
      add(:state, :link_states)
      timestamps(type: :utc_datetime)
    end
  end

  def down do
    drop(table(:links))
  end
end
