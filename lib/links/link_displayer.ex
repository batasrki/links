defmodule Links.LinkDisplayer do
  alias Links.Repo

  def to_list(pagination_config) do
    sort_direction = Map.get(pagination_config, :sort_direction, :asc)
    archived = convert_from(pagination_config, :archived)
    per_page = convert_from(pagination_config, :per_page)
    page = convert_from(pagination_config, :page)

    Repo.list(
      sort_direction,
      archived,
      per_page,
      page
    )
  end

  defp convert_from(pagination_config, :archived) do
    case Map.fetch(pagination_config, :archived) do
      :error -> false
      {:ok, val} -> String.to_existing_atom(val)
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
    Repo.list()
  end

  def to_json_list(params) do
    to_list(params) |> Poison.encode!()
  end
end
