defmodule Bezirke.Repo.Migrations.CreateSalesFigures do
  use Ecto.Migration

  def change do
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
