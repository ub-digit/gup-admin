import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
# config :gup_index_manager, GupIndexManager.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "gup_index_manager_test#{System.get_env("MIX_TEST_PARTITION")}",
#   pool: Ecto.Adapters.SQL.Sandbox,
#   pool_size: 10

config :gup_index_manager, GupIndexManager.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "gup_index_manager_dev",
  port: "5443",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gup_index_manager, GupIndexManagerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "bbhdtjP53s+sX/9H48R4ovCtt73QV7pI1Rqx3Lg+bLwTMwop2TjGV7H+TsMQRTHH",
  server: false

# In test we don't send emails.
config :gup_index_manager, GupIndexManager.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Config elastic search person index name
config :gup_index_manager, :person_index_name, "persons_test_index"
