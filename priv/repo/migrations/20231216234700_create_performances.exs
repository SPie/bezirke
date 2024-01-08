defmodule Bezirke.Repo.Migrations.CreatePerformances do
  use Ecto.Migration

  def change do
    create table(:performances) do
      add :uuid, :uuid
      add :played_at, :utc_datetime
      add :capacity, :integer
      add :production_id, references(:productions)
      add :venue_id, references(:venues)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:performances, [:uuid])
    create index(:performances, [:production_id])
    create index(:performances, [:venue_id])
  end
end
