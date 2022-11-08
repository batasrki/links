defmodule Links.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string

      timestamps(type: :utc_datetime, default: "NOW()")
    end

  end
end
