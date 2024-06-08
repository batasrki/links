defmodule Links.Accounts.Tokens do
  alias Phoenix.Token
  alias LinksWeb.Endpoint

  # 10 minute timeout
  @login_request_max_age 60 * 10
  @login_request_salt Application.compile_env(
                        :links,
                        :login_request_salt,
                        System.fetch_env!("SECRET_KEY_BASE")
                      )

  def sign_login_request(login_request) do
    Token.sign(Endpoint, @login_request_salt, login_request.id)
  end

  def verify_login_request(token) do
    Token.verify(Endpoint, @login_request_salt, token, max_age: @login_request_max_age)
  end
end
