defmodule Chico.Repo do
  use Ecto.Repo,
    otp_app: :chico,
    adapter: Ecto.Adapters.Postgres
end
