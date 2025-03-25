defmodule Bezirke.Repo.Migrations.PerformancesAddCancelledAtColumn do
  use Ecto.Migration

  def change do
    alter table("performances") do
      add :cancelled_at, :utc_datetime
    end
  end
end
