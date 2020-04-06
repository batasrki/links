defmodule Links.Repo.Migrations.AssociateLinksToUser do
  use Ecto.Migration
  import Ecto.Query

  def up do
    alter(table(:links)) do
      remove(:users_id)
      add(:user_id, references(:users), null: true)
    end

    flush()

    case from(u in Links.User, select: u.id) |> Links.Repo.all() do
      [user_id] ->
        from(l in Links.Link, update: [set: [user_id: ^user_id]]) |> Links.Repo.update_all([])

      [] ->
        nil
        # do nothing
    end
  end
end
