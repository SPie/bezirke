defmodule Bezirke.Statistics do
  @moduledoc """
  The Statistics context.
  """

  alias Bezirke.Events
  alias Bezirke.Events.Event
  alias Bezirke.Sales.SalesFigures

  def build_chart([], _), do: {[], [], []}

  def build_chart(data, use_percent) do
    dates = get_start_and_end_date(data)

    labels =
      dates
      |> build_labels([])
      |> Enum.reverse()

    events = get_events_for_chart(dates)

    datasets = build_datasets(labels, data, use_percent)

    {labels, datasets, events}
  end

  defp get_start_and_end_date([]), do: {}

  defp get_start_and_end_date(data) do
    dates =
      data
      |> Enum.flat_map(fn {_, sales_figures, _} ->
        Enum.map(sales_figures, &(DateTime.to_date(&1.record_date)))
      end)
      |> Enum.sort_by(&(&1), Date)

    start_date =
      dates
      |> List.first()
      |> Date.add(-1)

    end_date =
      dates
      |> List.last()
      |> Date.add(1)

    {start_date, end_date}
  end

  defp build_labels({}, _), do: []

  defp build_labels({current_date, end_date}, labels) do
    case Date.compare(current_date, end_date) do
      :eq -> [current_date | labels]
      _ -> build_labels({Date.add(current_date, 1), end_date}, [current_date | labels])
    end
  end

  defp build_datasets(labels, data, use_percent) do
    data
    |> Enum.map(fn {label, sales_figures, capacity} ->
      dataset =
        sales_figures
        |> Enum.sort_by(&(&1.record_date), DateTime)
        |> do_build_dataset(labels, [])
        |> Enum.reverse()

      dataset = if use_percent == "true" do
        dataset
        |> Enum.map(fn tickets_count -> (tickets_count / capacity * 100) end)
      else
        dataset
      end

      %{label: label, data: dataset}
    end)
  end

  defp do_build_dataset(_, [], tickets_count), do: tickets_count

  defp do_build_dataset([], [_ | next_dates], [latest_tickets_count | _] = tickets_count) do
    do_build_dataset([], next_dates, [latest_tickets_count | tickets_count])
  end

  defp do_build_dataset(sales_figures, [current_date | next_dates], []) do
    {total_tickets_count, sales_figures} = sum_tickets_count(0, current_date, sales_figures)

    do_build_dataset(sales_figures, next_dates, [total_tickets_count])
  end

  defp do_build_dataset(sales_figures, [current_date | next_dates], [latest_tickets_count | _] = tickets_count) do
    {total_tickets_count, sales_figures} = sum_tickets_count(latest_tickets_count, current_date, sales_figures)

    do_build_dataset(sales_figures, next_dates, [total_tickets_count | tickets_count])
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

  defp get_events_for_chart({}), do: []

  defp get_events_for_chart({start_date, end_date}) do
    Events.get_events_for_period(start_date, end_date)
    |> Enum.map(fn event ->
      event
      |> set_maximum_started_at(start_date)
      |> set_minimum_ended_at(end_date)
    end)
  end

  defp set_maximum_started_at(%Event{started_at: started_at} = event, start_date) do
    case Date.compare(start_date, started_at) do
      :gt -> %Event{event | started_at: start_date}
      _ -> event
    end
  end

  defp set_minimum_ended_at(%Event{ended_at: nil} = event, _), do: event

  defp set_minimum_ended_at(%Event{ended_at: ended_at} = event, end_date) do
    case Date.compare(end_date, ended_at) do
      :lt -> %Event{event | ended_at: end_date}
      _ -> event
    end
  end

  def set_event_times_boundaries(events, []), do: events

  def set_event_times_boundaries(events, dates) do
    start_date =
      dates
      |> List.first()

    end_date =
      dates
      |> List.last()

    events
    |> Enum.map(fn event ->
      event
      |> set_maximum_started_at(start_date)
      |> set_minimum_ended_at(end_date)
    end)
  end
end
