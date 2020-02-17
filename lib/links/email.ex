defmodule Links.Email do
  use Bamboo.Phoenix, view: LinksWeb.EmailView
  import Bamboo.Email
  alias Links.Accounts.Tokens

  def login_request(user, login_request) do
    new_email()
    |> to(user.email)
    |> from("noreply@s2dd.ca")
    |> subject("Log into Links")
    |> assign(:token, Tokens.sign_login_request(login_request))
    |> render("login_request.html")
  end
end
