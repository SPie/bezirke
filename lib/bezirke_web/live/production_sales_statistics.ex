defmodule BezirkeWeb.ProductionSalesStatistics do
  use BezirkeWeb, :live_view

  alias Bezirke.Sales
  alias Bezirke.Tour

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()

    production_statistics =
      seasons
      |> get_active_season()
      |> Tour.get_productions_for_season()
      |> Enum.map(&get_production_statistics/1)

    {labels, datasets} =
      production_statistics
      |> build_chart()

    socket =
      socket
      |> assign(seasons: get_seasons_options(seasons))
      |> assign(productions_statistics: production_statistics)
      |> assign(labels: labels)
      |> assign(datasets: datasets)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        Production Sales Statistics
      </.header>
      <.input id="season" name="season" label="Season" type="select" options={@seasons} value="" />

      <div>
        <%= for production_statistic <- @productions_statistics do %>
          <div>
            <h2>
              <%= production_statistic.production.title %>
            </h2>
            <p>
              <%= production_statistic.tickets_count %>
                / <%= production_statistic.capacity %>
                (<%=  production_statistic.tickets_count / production_statistic.capacity * 100
                  |> Decimal.from_float()
                  |> Decimal.round(2)
                %> %)
            </p>
          </div>
        <% end %>
        <canvas
          id="production-sales"
          phx-hook="ChartJS"
          data-labels={Jason.encode!(@labels)}
          data-datasets={
            @datasets
            |> Enum.map(fn {tickets_count, %Bezirke.Tour.Production{title: label}} ->
              %{label: label, data: tickets_count}
            end)
            |> Jason.encode!()
          }
        />
      </div>
    """
  end

  defp get_active_season(seasons) do
    case Enum.find(seasons, fn season -> season.active end) do
      nil -> List.first(seasons)
      active_season -> active_season
    end
  end

  defp get_seasons_options(seasons) do
    seasons
    |> Enum.map(fn season ->
      [
        key: season.name,
        value: season.uuid,
        selected: season.active,
      ]
    end)
  end

  defp get_production_statistics(production) do
    sales_figures = Sales.get_sales_figures_for_production(production)
    capacity = Tour.get_total_capacity(production)

    tickets_count =
      sales_figures
      |> Enum.reduce(
        0,
        fn %Sales.SalesFigures{tickets_count: tickets_count}, total_tickets_count ->
          total_tickets_count + tickets_count
        end
      )

    %{
      production: production,
      sales_figures: sales_figures,
      capacity: capacity,
      tickets_count: tickets_count,
    }
  end

  defp build_chart(production_statistics) do
    labels = get_labels(production_statistics)

    datasets = build_datasets(labels, production_statistics)

    {labels, datasets}
  end

  defp get_labels(production_statistics) do
    sales_figures =
      production_statistics
      |> Enum.flat_map(fn %{sales_figures: sales_figures} ->
        Enum.map(sales_figures, &(DateTime.to_date(&1.record_date)))
      end)
      |> Enum.sort_by(&(&1), Date)

    start_date =
      sales_figures
      |> List.first()
      |> Date.add(-1)

    end_date =
      sales_figures
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

  defp build_datasets(labels, production_statistics) do
    production_statistics
    |> Enum.map(fn %{production: production, sales_figures: sales_figures} ->
      dataset =
        sales_figures
        |> Enum.sort_by(&(&1.record_date), DateTime)
        |> build_dataset(labels, [])
        |> Enum.reverse()

      {dataset, production}
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
      %Bezirke.Sales.SalesFigures{record_date: record_date, tickets_count: tickets_count}
      | next_sales_figures
    ] = sales_figures
  ) do
    case Date.compare(current_date, DateTime.to_date(record_date)) do
      :eq -> sum_tickets_count(tickets_count + total_tickets_count, current_date, next_sales_figures)
      _ -> {total_tickets_count, sales_figures}
    end
  end
end
