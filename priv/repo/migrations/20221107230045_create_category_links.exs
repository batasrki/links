defmodule Links.Repo.Migrations.CreateCategoryLinks do
  use Ecto.Migration

  def change do
    create table(:category_links, primary_key: false) do
      add :category_id, references(:categories), primary_key: true
      add :link_id, references(:links), primary_key: true

      timestamps(type: :utc_datetime, default: "NOW()")
    end

    create index(:category_links, [:category_id])
    create index(:category_links, [:link_id])
    create unique_index(:category_links, [:category_id, :link_id], name: :category_link_unique_idx)
  end
end
