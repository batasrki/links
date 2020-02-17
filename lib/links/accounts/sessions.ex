defmodule Links.Accounts.Sessions do
  alias Links.Accounts.Session
  alias Links.Repo

  def get_by_id(id) do
    Repo.get(Session, id)
  end
end
