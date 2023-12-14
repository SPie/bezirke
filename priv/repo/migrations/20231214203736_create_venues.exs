defmodule Bezirke.Repo.Migrations.CreateVenues do
  use Ecto.Migration

  def change do
    create table(:venues) do
      add :uuid, :uuid
      add :name, :string
      add :description, :text
      add :capacity, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:venues, [:uuid])
  end
end
