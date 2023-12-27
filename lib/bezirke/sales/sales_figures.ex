defmodule Bezirke.Sales.SalesFigures do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sales_figures" do
    field :uuid, Ecto.UUID
    field :record_date, :utc_datetime
    field :tickets_count, :integer

    belongs_to :performance, Bezirke.Tour.Performance

    timestamps(type: :utc_datetime)

    field :performance_uuid, Ecto.UUID, virtual: true
  end

  @doc false
  def changeset(sales_figures, attrs) do
    sales_figures
    |> cast(attrs, [:uuid, :record_date, :tickets_count, :performance_uuid])
    |> cast_performance_id()
    |> validate_required([:uuid, :record_date, :tickets_count, :performance_id])
    |> unique_constraint(:uuid)
  end

  defp cast_performance_id(changeset) do
    case get_change(changeset, :performance_uuid) do
      nil -> changeset
      performance_uuid ->
        performance = Bezirke.Tour.get_performance_by_uuid!(performance_uuid)
        put_change(changeset, :performance_id, performance.id)
    end
  end
end

defimpl Phoenix.Param, for: Bezirke.Sales.SalesFigures do
  def to_param(%{uuid: uuid}), do: uuid
end
