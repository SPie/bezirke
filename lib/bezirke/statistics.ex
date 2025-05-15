defmodule Bezirke.Statistics do
  @moduledoc """
  The Statistics context.
  """

  alias Bezirke.Statistics.Dataset
  alias Bezirke.Statistics.TicketsCount
  alias Bezirke.Statistics.StatisticsData
  alias Bezirke.Events
  alias Bezirke.Events.Event
  alias Bezirke.Sales.SalesFigures

  def build_sales_chart([], _, _), do: {[], []}

  def build_sales_chart(data, use_percent?, with_subscriber?) do
    dates = get_start_and_end_date(data)

    events = get_events_for_chart(dates)

    datasets = build_sales_dataset(data, use_percent?, with_subscriber?)

    {datasets, events}
  end

  defp get_start_and_end_date([]), do: {}

  defp get_start_and_end_date(data) do
    dates =
      data
      |> Enum.flat_map(fn %StatisticsData{sales_figures: sales_figures} ->
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

  defp build_sales_dataset(data, use_percent?, with_subscriber?) do
    data
    |> Enum.map(fn %StatisticsData{
      label: label,
      sales_figures: sales_figures,
      capacity: capacity,
      subscribers_quantity: subscribers_quantity
    } ->
      ticket_counts =
        sales_figures
        |> Enum.sort_by(&(&1.record_date), {:asc, DateTime})
        |> add_up_ticket_counts([])
        |> Enum.reverse()

      %Dataset{label: label, ticket_counts: ticket_counts}
    end)
  end

  defp add_up_ticket_counts([], ticket_counts), do: ticket_counts

  defp add_up_ticket_counts(
    [%SalesFigures{record_date: record_date, tickets_count: tickets_count} | next_sales_figures],
    []
  ) do
    add_up_ticket_counts(next_sales_figures, [%TicketsCount{date: DateTime.to_date(record_date), tickets_count: tickets_count}])
  end

  defp add_up_ticket_counts(
    [%SalesFigures{record_date: record_date, tickets_count: tickets_count} | next_sales_figures],
    [%TicketsCount{date: current_date, tickets_count: current_tickets_count} | prev_ticket_counts] = ticket_counts
  ) do
    record_date = DateTime.to_date(record_date)

    case Date.compare(record_date, current_date) do
      :eq -> add_up_ticket_counts(next_sales_figures, [%TicketsCount{date: current_date, tickets_count: current_tickets_count + tickets_count} | prev_ticket_counts])
      _ -> add_up_ticket_counts(next_sales_figures, [%TicketsCount{date: record_date, tickets_count: current_tickets_count + tickets_count} | ticket_counts])
    end
  end

  defp build_datasets(labels, data, use_percent, with_subscriber?) do
    data
    |> Enum.map(fn %StatisticsData{
      label: label,
      sales_figures: sales_figures,
      capacity: capacity,
      subscribers_quantity: subscribers_quantity
    } ->
      dataset =
        sales_figures
        |> Enum.sort_by(&(&1.record_date), DateTime)
        |> do_build_dataset(labels, [])
        |> Enum.reverse()
        |> Enum.map(fn tickets_count ->
          if with_subscriber? == false || with_subscriber? == "false" do
            max(tickets_count - subscribers_quantity, 0)
          else
            tickets_count
          end
        end)

      dataset = if use_percent == "true" || use_percent == true do
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

  def set_event_times_boundaries(events, nil, nil), do: events

  def set_event_times_boundaries(events, start_date, end_date) do
    events
    |> Enum.map(fn event ->
      event
      |> set_maximum_started_at(start_date)
      |> set_minimum_ended_at(end_date)
    end)
  end
end
