defmodule Links.LinkMutator do
  def update(link, params) do
    params = Map.put(params, "added_at", link.added_at)
    params = Map.put(params, "archive", link.archive)

    Links.Repo.update(link.id, params)
  end

  def create(params) do
    params = Map.put(params, "added_at", NaiveDateTime.utc_now())
    Links.Repo.create(params)
  end
end
