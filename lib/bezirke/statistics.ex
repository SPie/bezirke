defmodule Bezirke.Statistics do
  @moduledoc """
  The Statistics context.
  """

  alias Bezirke.Sales.SalesFigures

  def build_chart([]), do: {[], []}

  def build_chart(data) do
    labels = 
      data
      |> Enum.flat_map(fn {_, sales_figures} ->
        Enum.map(sales_figures, &(DateTime.to_date(&1.record_date)))
      end)
      |> get_labels()

    datasets = build_datasets(labels, data)

    {labels, datasets}
  end

  defp get_labels(dates) do
    dates
    |> Enum.sort_by(&(&1), Date)
    |> get_labels_from_sales_figures()
  end

  defp get_labels_from_sales_figures([]), do: []

  defp get_labels_from_sales_figures(dates) do
    start_date =
      dates
      |> List.first()
      |> Date.add(-1)

    end_date =
      dates
      |> List.last()
      |> Date.add(1)

    build_labels(start_date, end_date, [])
    |> Enum.reverse()
  end

  defp build_labels(current_date, end_date, labels) do
    case Date.compare(current_date, end_date) do
      :eq -> [current_date | labels]
      _ -> build_labels(Date.add(current_date, 1), end_date, [current_date | labels])
    end
  end

  defp build_datasets(labels, data) do
    data
    |> Enum.map(fn {label, sales_figures} ->
      dataset =
        sales_figures
        |> Enum.sort_by(&(&1.record_date), DateTime)
        |> build_dataset(labels, [])
        |> Enum.reverse()

      %{label: label, data: dataset}
    end)
  end

  defp build_dataset(_, [], tickets_count), do: tickets_count

  defp build_dataset([], [_ | next_dates], [latest_tickets_count | _] = tickets_count) do
    build_dataset([], next_dates, [latest_tickets_count | tickets_count])
  end

  defp build_dataset(sales_figures, [current_date | next_dates], []) do
    {total_tickets_count, sales_figures} = sum_tickets_count(0, current_date, sales_figures)

    build_dataset(sales_figures, next_dates, [total_tickets_count])
  end

  defp build_dataset(sales_figures, [current_date | next_dates], [latest_tickets_count | _] = tickets_count) do
    {total_tickets_count, sales_figures} = sum_tickets_count(latest_tickets_count, current_date, sales_figures)

    build_dataset(sales_figures, next_dates, [total_tickets_count | tickets_count])
  end

  defp sum_tickets_count(total_tickets_count, _, []), do: {total_tickets_count, []}

  defp sum_tickets_count(
    total_tickets_count,
    current_date,
    [
      %SalesFigures{record_date: record_date, tickets_count: tickets_count}
      | next_sales_figures
    ] = sales_figures
  ) do
    case Date.compare(current_date, DateTime.to_date(record_date)) do
      :eq -> sum_tickets_count(tickets_count + total_tickets_count, current_date, next_sales_figures)
      _ -> {total_tickets_count, sales_figures}
    end
  end
end
