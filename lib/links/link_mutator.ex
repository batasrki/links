defmodule Links.LinkMutator do
  def update(link, params) do
    Links.Repo.update(link.id, params)
  end

  def create(params) do
    params = Map.merge(params, %{"added_at" => NaiveDateTime.utc_now(), "title" => params["url"]})
    result = Links.Repo.create(params)
    Links.CrawlerService.fetch_title(params)
    result
  end
end
