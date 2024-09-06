defmodule Medusa.Repo do
  use Ecto.Repo,
    otp_app: :medusa,
    adapter: Ecto.Adapters.Postgres
end
