defmodule Bezirke.Repo.Migrations.CreateProductions do
  use Ecto.Migration

  def change do
    create table(:productions) do
      add :uuid, :uuid, null: false
      add :title, :string, null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:productions, [:uuid])
  end
end
