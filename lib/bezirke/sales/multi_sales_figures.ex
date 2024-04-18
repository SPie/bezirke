defmodule Bezirke.Sales.MultiSalesFigures do
  use Ecto.Schema

  import Ecto.Changeset

  alias Bezirke.Repo
  alias Bezirke.Sales.SalesFigures

  embedded_schema do
    field :record_date, :utc_datetime
    embeds_many :sales_figures, SalesFigures
  end

  def changeset(multi_sales_figures, attrs) do
    attrs
    |> hydrate_sales_figures()
    |> do_changeset(multi_sales_figures)
  end

  def changeset_final(multi_sales_figures, attrs) do
    attrs
    |> hydrate_sales_figures()
    |> do_changeset_final(multi_sales_figures)
  end

  defp hydrate_sales_figures(%{"record_date" => record_date, "sales_figures" => sales_figures} = attrs)
  when record_date != "" do
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

    Map.put(attrs, "sales_figures", sales_figures)
  end

  defp hydrate_sales_figures(%{"sales_figures" => sales_figures} = attrs) do
    sales_figures =
      sales_figures
      |> Enum.map(fn {index, row} ->
        row =
          row
          |> Map.put("uuid", Repo.generate_uuid())

        {index, row}
      end)
      |> Enum.into(%{})

    Map.put(attrs, "sales_figures", sales_figures)
  end

  defp hydrate_sales_figures(attrs), do: attrs

  defp do_changeset(attrs, multi_sales_figures) do
    multi_sales_figures
    |> cast(attrs, [:record_date])
    |> validate_required([:record_date])
    |> cast_embed(:sales_figures, with: &SalesFigures.changeset_multi/2)
  end

  defp do_changeset_final(attrs, multi_sales_figures) do
    multi_sales_figures
    |> cast(attrs, [])
    |> cast_embed(:sales_figures, with: &SalesFigures.changeset_multi_final/2)
  end
end
