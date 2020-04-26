defmodule Links.Link do
  use Ecto.Schema
  import Ecto.{Query, Changeset}
  require Logger

  schema "links" do
    field(:url, :string)
    field(:title, :string)
    field(:client, :string)
    field(:added_at, :utc_datetime)
    field(:state, :string)
    belongs_to(:user, Links.User)
    timestamps(type: :utc_datetime)
  end

  ## Queries block ##
  def list(filter_config, pagination_config) do
    sort_direction = from_config(pagination_config)
    query = __MODULE__ |> order_by(^sort_direction)

    query = paginate(query, pagination_config)

    query = build_filter(query, filter_config)

    # Debugging code
    {generated_sql, params} = Ecto.Adapters.SQL.to_sql(:all, Links.Repo, query)
    Logger.info(generated_sql)
    Logger.info(inspect(params))

    Logger.info(Enum.join(Enum.map(filter_config, fn {k, v} -> "#{k} => #{v}" end), "; "))
    Logger.info(Enum.join(Enum.map(pagination_config, fn {k, v} -> "#{k} => #{v}" end), "; "))

    query |> Links.Repo.all()
  end

  defp from_config(%{sort_direction: "asc"}) do
    [asc: :added_at]
  end

  defp from_config(%{sort_direction: "desc"}) do
    [desc: :added_at]
  end

  defp paginate(query, %{per_page: per_page, after: link_id})
       when is_number(per_page) and is_number(link_id) do
    query
    |> where([l], l.id > ^link_id)
    |> limit(^per_page)
  end

  defp paginate(query, %{per_page: per_page})
       when is_number(per_page) do
    query
    |> limit(^per_page)
  end

  defp paginate(query, _) do
    query
  end

  defp build_filter(query, filter_config) do
    {user_id_map, _} = Map.split(filter_config, [:user_id])
    filter_config = Map.delete(filter_config, :user_id)
    query = filter(query, user_id_map)
    filter(query, filter_config)
  end

  defp filter(query, %{user_id: user_id}) do
    query |> where([link], link.user_id == ^user_id)
  end

  defp filter(query, %{state: nil}) do
    query
  end

  defp filter(query, %{state: state}) do
    query |> where([link], link.state == ^state)
  end

  defp filter(query, _) do
    query
  end

  def find_by_url(url) do
    __MODULE__ |> Links.Repo.get_by!(url: url)
  end

  def find_by_id(id) do
    __MODULE__ |> Links.Repo.get!(id)
  end

  ## END Queries block ##

  def update(link, params) do
    changeset = __MODULE__.update_changeset(link, params)
    Links.Repo.update(changeset)
  end

  def update_changeset(link, params) do
    link
    |> cast(params, [:url, :title, :client, :state])
    |> validate_required([:url, :client, :title])
    |> validate_format(:url, ~r/^http/)
    |> validate_inclusion(:state, ["active", "archived", "unreachable"])
  end

  def create(params) do
    changeset = __MODULE__.create_changeset(%Links.Link{}, params)
    Links.Repo.insert(changeset)
  end

  def create_changeset(link, params) do
    link
    |> cast(params, [:url, :client, :added_at, :title, :state, :user_id])
    |> validate_required([:url, :client, :user_id])
    |> validate_format(:url, ~r/^http/)
    |> unique_constraint(:url)
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
