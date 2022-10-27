import Config
config :links, :login_request_salt, System.fetch_env!("SECRET_KEY_BASE")
config :links, :mailgun_api_key, System.fetch_env!("MAILGUN_API_KEY")
