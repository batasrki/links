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

    query = paginate(query, filter_pagination_config)

    query = filter(query, filter_pagination_config)

    # Debugging code
    query = Query.select(query)
    Logger.info(query.sql)

    Logger.info(
      Enum.join(Enum.map(filter_pagination_config, fn {k, v} -> "#{k} => #{v}" end), "; ")
    )

    {:ok, result} = query |> Db.run()

    result
  end

  def find_by_url(url) do
    {:ok, result} =
      Query.db(:links)
      |> Query.filter(url: url)
      |> Query.limit(1)
      |> Db.run()

    result
  end

  defp paginate(query, %{per_page: per_page, page: page}) when is_number(per_page) do
    query
    |> Query.limit(per_page)
    |> Query.skip((page - 1) * per_page)
  end

  defp paginate(query, _) do
    query
  end

  defp filter(query, %{archived: archived}) when is_boolean(archived) do
    query |> Query.filter(archive: archived)
  end

  defp filter(query, _) do
    query
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
      client: item["client"],
      inserted_at: NaiveDateTime.utc_now(),
      updated_at: NaiveDateTime.utc_now()
    ]
  end
end
