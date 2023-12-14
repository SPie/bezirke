defmodule Bezirke.Repo do
  use Ecto.Repo,
    otp_app: :bezirke,
    adapter: Ecto.Adapters.Postgres

  def generate_uuid(), do: Ecto.UUID.generate()
end
