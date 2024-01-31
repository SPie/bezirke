defmodule Bezirke.Sales.SalesFigures do
  alias Bezirke.Sales
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
    |> cast_performance()
    |> validate_required([:uuid, :record_date, :tickets_count, :performance])
    |> unique_constraint(:uuid)
    |> cast_tickets_count()
  end

  defp cast_performance(%Ecto.Changeset{changes: %{performance_uuid: performance_uuid}} = changeset) do
    case Bezirke.Tour.get_performance_by_uuid(performance_uuid) do
      nil -> changeset
      performance -> put_change(changeset, :performance, performance)
    end
  end

  defp cast_performance(changeset), do: changeset

  defp cast_tickets_count(%Ecto.Changeset{changes: %{
    performance: %Ecto.Changeset{data: performance},
    tickets_count: tickets_count,
    record_date: record_date
  }} = changeset) do
    total_tickets_count = Sales.get_current_tickets_count_for_performance(performance, record_date)

    changeset
    |> put_change(:tickets_count, tickets_count - total_tickets_count)
  end

  defp cast_tickets_count(changeset), do: changeset
end

defimpl Phoenix.Param, for: Bezirke.Sales.SalesFigures do
  def to_param(%{uuid: uuid}), do: uuid
end
