defmodule Bezirke.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :uuid, :uuid, null: false
      add :label, :string, null: false
      add :description, :text
      add :started_at, :date, null: false
      add :ended_at, :date

      timestamps(type: :utc_datetime)
    end

    create unique_index(:events, [:uuid])
  end
end
