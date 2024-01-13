defmodule Bezirke.Repo.Migrations.CreateTables do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :uuid, :uuid
      add :name, :string
      add :active, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:seasons, [:uuid])

    create table(:productions) do
      add :uuid, :uuid, null: false
      add :title, :string, null: false
      add :description, :text
      add :season_id, references(:seasons)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:productions, [:uuid])
    create index(:productions, [:season_id])

    create table(:venues) do
      add :uuid, :uuid
      add :name, :string
      add :description, :text
      add :capacity, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:venues, [:uuid])

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

    create table(:sales_figures) do
      add :uuid, :uuid
      add :record_date, :utc_datetime
      add :tickets_count, :integer
      add :performance_id, references(:performances)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sales_figures, [:uuid])
    create index(:sales_figures, [:performance_id])
  end
end
