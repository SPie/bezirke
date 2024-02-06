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
  end

  @doc false
  def changeset(sales_figures, attrs) do
    sales_figures
    |> cast(attrs, [:uuid, :record_date, :tickets_count])
    |> validate_required([:uuid, :record_date, :tickets_count, :performance])
    |> unique_constraint(:uuid)
    |> cast_tickets_count()
  end

  def changeset_for_update(sales_figures, attrs) do
    sales_figures
    |> cast(attrs, [:record_date, :tickets_count])
    |> validate_required([:record_date, :tickets_count])
    |> cast_tickets_count()
  end

  defp cast_tickets_count(%Ecto.Changeset{changes: %{
    performance: %Ecto.Changeset{data: performance},
    tickets_count: tickets_count,
    record_date: record_date,
  }} = changeset) do
    changeset
    |> calculate_tickets_count(performance, tickets_count, record_date)
  end

  defp cast_tickets_count(%Ecto.Changeset{
    changes: %{tickets_count: tickets_count, record_date: record_date},
    data: %{id: id, performance: performance},
  } = changeset) do
    changeset
    |> calculate_tickets_count(performance, tickets_count, record_date, id)
  end

  defp cast_tickets_count(%Ecto.Changeset{
    changes: %{tickets_count: tickets_count},
    data: %{id: id, performance: performance, record_date: record_date},
  } = changeset) do
    changeset
    |> calculate_tickets_count(performance, tickets_count, record_date, id)
  end

  defp cast_tickets_count(changeset), do: changeset

  defp calculate_tickets_count(
    changeset,
    performance,
    tickets_count,
    record_date,
    sales_figures_id \\ nil
  ) do
    total_tickets_count = Sales.get_current_tickets_count_for_performance(
      performance,
      record_date,
      sales_figures_id
    )

    changeset
    |> put_change(:tickets_count, tickets_count - total_tickets_count)
  end
end

defimpl Phoenix.Param, for: Bezirke.Sales.SalesFigures do
  def to_param(%{uuid: uuid}), do: uuid
end
