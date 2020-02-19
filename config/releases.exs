import Config
config :links, :login_request_salt, System.fetch_env!("SECRET_KEY_BASE")
config :links, :sendgrid_api_key, System.fetch_env!("SENDGRID_API_KEY")
