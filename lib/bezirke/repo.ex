defmodule Bezirke.Repo do
  use Ecto.Repo,
    otp_app: :bezirke,
    adapter: Ecto.Adapters.Postgres
end
