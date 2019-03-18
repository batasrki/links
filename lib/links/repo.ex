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

  def by_last_added_at(filter_pagination_config) do
    query = Query.db(:links) |> Query.sort(:added_at, filter_pagination_config[:sort_direction])

    query =
      if Map.has_key?(filter_pagination_config, :per_page) do
        query
        |> Query.limit(filter_pagination_config[:per_page])
        |> Query.skip(filter_pagination_config[:page] - 1 * filter_pagination_config[:per_page])
      end

    {:ok, result} = query |> Db.run()
    result
  end

  def list(filter_pagination_config) do
    query = Query.db(:links) |> Query.sort(:added_at, filter_pagination_config[:sort_direction])

    query =
      if Map.has_key?(filter_pagination_config, :per_page) do
        query
        |> Query.limit(filter_pagination_config[:per_page])
        |> Query.skip((filter_pagination_config[:page] - 1) * filter_pagination_config[:per_page])
      else
        query
      end

    query =
      if Map.has_key?(filter_pagination_config, :archived) do
        query |> Query.filter(archive: filter_pagination_config[:archived])
      else
        query
      end

    # Debugging code
    # query = Query.select(query)
    # IO.inspect(query.sql)
    # IO.inspect(filter_pagination_config)

    {:ok, result} = query |> Db.run()

    result
  end

  def batch_save!(redis_list) do
    prepared_delta =
      for item <- redis_list,
          into: [],
          do: list_from_map(item)

    if prepared_delta != [] do
      [ok: result] =
        Query.db(:links)
        |> Query.bulk_insert(prepared_delta)
        |> Db.transact_batch()

      result
    end
  end

  def list_from_map(item) do
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
