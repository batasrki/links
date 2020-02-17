defmodule LinksWeb.Router do
  use LinksWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", LinksWeb do
    # Use the default browser stack
    pipe_through(:browser)

    resources("/links", LinkController)
    resources("/users", UserController, only: [:index, :show, :edit, :update])
    resources("/registrations", RegistrationController, only: [:new, :create])

    resources("/login_requests", LoginRequestController,
      only: [:new, :create, :show],
      param: "token"
    )

    get("/", LoginRequestController, :new)
    get("/register", RegistrationController, :new)
  end

  scope "/api", LinksWeb do
    pipe_through(:api)

    get("/", ApiController, :index)
  end

  if Mix.env() == :dev do
    forward("/sent-emails", Bamboo.SentEmailViewerPlug)
  end
end
