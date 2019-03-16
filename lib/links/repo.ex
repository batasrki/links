defmodule Links.Repo do
  alias Moebius.{Query, Db}
  require Logger

  def paginated_list(since_id \\ nil) do
    query =
      Query.db(:links)
      |> Query.sort(:id, :asc)
      |> Query.filter("id > #{since_id}")
      |> Query.select()

    {:ok, result} = query |> Db.run()
    result
  end

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

  def batch_save!(redis_list) do
    [ok: result] =
      Query.db(:links)
      |> Query.bulk_insert(
        for item <- redis_list,
            into: [],
            do: list_from_map(item)
      )
      |> Db.transact_batch()

    result
  end

  defp list_from_map(item) do
    added_at = DateTime.from_unix!(item["timestamp"]) |> DateTime.to_naive()

    [
      title: item["title"],
      url: item["url"],
      added_at: added_at,
      archive: item["archive"],
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    ]
  end
end
