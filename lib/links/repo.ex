defmodule Links.Repo do
  alias Moebius.{Query, Db}
  require Logger

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
      # |> Query.limit(1)
      |> Db.run()

    result
  end

  def find_by_id(id) do
    {:ok, result} =
      Query.db(:links)
      |> Query.filter(id: id)
      |> Db.run()

    result
  end

  defp paginate(query, %{per_page: per_page, after: id})
       when is_number(per_page) and is_number(id) do
    query
    |> Query.filter("id > $1", id)
    |> Query.limit(per_page)
  end

  defp paginate(query, %{per_page: per_page})
       when is_number(per_page) do
    query
    |> Query.limit(per_page)
  end

  defp paginate(query, _) do
    query
  end

  defp filter(query, %{state: nil}) do
    query
  end

  defp filter(query, %{state: state}) do
    query |> Query.filter(state: state)
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

  def update(id, params) do
    prepared_item = list_from_map(params)

    query =
      Query.db(:links)
      |> Query.filter(id: id)
      |> Query.update(prepared_item)

    query |> Db.run()
  end

  def create(params) do
    prepared_item = list_from_map(params)
    prepared_item = prepared_item ++ [inserted_at: NaiveDateTime.utc_now()]

    query =
      Query.db(:links)
      |> Query.insert(prepared_item)

    query |> Db.run()
  end

  def list_from_map(item) do
    item =
      cond do
        item["timestamp"] != nil ->
          converted_timestamp = DateTime.from_unix!(item["timestamp"]) |> DateTime.to_naive()
          item = Map.put(item, "added_at", converted_timestamp)
          Map.delete(item, "timestamp")

        item["timestamp"] == nil ->
          item
      end

    initial_list = for {k, v} <- item, into: [], do: {String.to_existing_atom(k), v}

    initial_list ++ [updated_at: NaiveDateTime.utc_now()]
  end
end
