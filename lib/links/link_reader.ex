defmodule Links.LinkReader do
  alias Links.Link

  def to_list(pagination_config) do
    filter_pagination_config = %{
      sort_direction: Map.get(pagination_config, :sort_direction, "asc")
    }

    filter_pagination_config =
      Map.put(
        filter_pagination_config,
        :state,
        convert_from(pagination_config, :state)
      )

    filter_pagination_config =
      Map.put(
        filter_pagination_config,
        :per_page,
        convert_from(pagination_config, :per_page)
      )

    filter_pagination_config =
      Map.put(filter_pagination_config, :page, convert_from(pagination_config, :page))

    Link.list(filter_pagination_config)
  end

  defp convert_from(pagination_config, :state) do
    case Map.fetch(pagination_config, :state) do
      :error -> nil
      {:ok, val} -> val
    end
  end

  defp convert_from(pagination_config, key) do
    case Map.fetch(pagination_config, key) do
      :error -> nil
      {:ok, ""} -> nil
      {:ok, val} -> String.to_integer(val)
    end
  end

  def to_list() do
    Link.list(%{})
  end

  def to_json_list(params) do
    to_list(params) |> Jason.encode!()
  end

  def by_id(id) do
    Link.find_by_id(String.to_integer(id))
  end

  def by_id_for_editing(id) do
    try do
      link = Link.find_by_id(String.to_integer(id))
      Links.Link.update_changeset(link, %{})
    rescue
      _e in Ecto.NoResultsError -> {:error, :not_found}
    end
  end
end
