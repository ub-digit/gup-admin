defmodule GupIndexManager.Repo do
  use Ecto.Repo,
    otp_app: :gup_index_manager,
    adapter: Ecto.Adapters.Postgres
end
