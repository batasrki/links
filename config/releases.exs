import Config
config :links, :login_request_salt, System.fetch_env!("SECRET_KEY_BASE")
config :links, :mandrill_api_key, System.fetch_env!("MANDRILL_API_KEY")
config :links, :mandrill_user_name, System.fetch_env!("MANDRILL_USERNAME")
