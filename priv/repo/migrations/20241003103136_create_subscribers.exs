defmodule Bezirke.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :uuid, :uuid
      add :quantity, :integer
      add :venue_id, references(:venues)
      add :season_id, references(:seasons)

      timestamps(type: :utc_datetime)
    end
  end
end
