defmodule Links.Repo do
  alias Moebius.{Query, Db}
  require Logger

  def list(sort_direction \\ :asc, archived \\ false, per_page \\ nil, page \\ nil) do
    query = Query.db(:links) |> Query.sort(:added_at, sort_direction)

    query =
      if per_page do
        query |> Query.limit(per_page) |> Query.skip((page - 1) * per_page)
      else
        query
      end

    query = query |> Query.filter(archive: archived)

    {:ok, result} = query |> Db.run()

    result
  end
end
