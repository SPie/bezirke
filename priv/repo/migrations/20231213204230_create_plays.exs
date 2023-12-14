defmodule Bezirke.Repo.Migrations.CreatePlays do
  use Ecto.Migration

  def change do
    create table(:plays) do
      add :uuid, :uuid, null: false
      add :title, :string, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:plays, [:uuid])
  end
end
