defmodule GupAdmin.Repo do
  use Ecto.Repo,
    otp_app: :gup_admin,
    adapter: Ecto.Adapters.Postgres
end
