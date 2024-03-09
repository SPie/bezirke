defmodule Bezirke.Sales.MultiSalesFigures do
  use Ecto.Schema

  import Ecto.Changeset

  alias Bezirke.Repo
  alias Bezirke.Sales.SalesFigures

  embedded_schema do
    field :record_date, :utc_datetime
    embeds_many :sales_figures, SalesFigures
  end

  def changeset(
    multi_sales_figures,
    %{"record_date" => record_date, "sales_figures" => sales_figures} = attrs
  ) when record_date != "" do
    sales_figures =
      sales_figures
      |> Enum.map(fn {index, row} ->
        row =
          row
          |> Map.put("record_date", record_date)
          |> Map.put("uuid", Repo.generate_uuid())

        {index, row}
      end)
      |> Enum.into(%{})

    do_changeset(multi_sales_figures, Map.put(attrs, "sales_figures", sales_figures))
  end

  def changeset(multi_sales_figures, %{"sales_figures" => sales_figures} = attrs) do
    sales_figures =
      sales_figures
      |> Enum.map(fn {index, row} ->
        row
        |> Map.put("uuid", Repo.generate_uuid())

        {index, row}
      end)
      |> Enum.into(%{})

    do_changeset(multi_sales_figures, Map.put(attrs, "sales_figures", sales_figures))
  end

  def changeset(multi_sales_figures, attrs) do
    do_changeset(multi_sales_figures, attrs)
  end

  defp do_changeset(multi_sales_figures, attrs) do
    multi_sales_figures
    |> cast(attrs, [:record_date])
    |> validate_required([:record_date])
    |> cast_embed(:sales_figures, with: &SalesFigures.changeset_multi/2)
  end
end
