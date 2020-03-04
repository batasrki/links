defmodule Links.Repo.Migrations.CreateStatssTableForGhActions do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:stats) do
      add(:click_count, :integer)
      add(:link_id, references(:links))
      timestamps(type: :utc_datetime)
    end
  end
end
