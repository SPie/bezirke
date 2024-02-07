defmodule BezirkeWeb.ProductionSalesStatistics do
  use BezirkeWeb, :live_view

  alias Bezirke.Sales
  alias Bezirke.Tour

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()

    {production_statistics, labels, datasets} =
      seasons
      |> Tour.get_active_season()
      |> get_view_data()

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
      <.form phx-change="select_season">
        <.input id="season" name="season" label="Season" type="select" options={@seasons} value=""/>
      </.form>

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
          data-datasets={Jason.encode!(@datasets)}
        />
      </div>
    """
  end

  def handle_event("select_season", %{"season" => season_uuid}, socket) do
    
    {production_statistics, labels, datasets} =
      season_uuid
      |> Tour.get_season_by_uuid!()
      |> get_view_data()

    socket =
      socket
      |> assign(productions_statistics: production_statistics)
      |> push_event("update-chart", %{labels: labels, datasets: datasets})

    {:noreply, socket}
  end

  defp get_view_data(season) do
    production_statistics =
      season
      |> Tour.get_productions_for_season()
      |> Enum.map(&get_production_statistics/1)

    {labels, datasets} =
      production_statistics
      |> Enum.map(fn %{production: production, sales_figures: sales_figures} ->
        {production, sales_figures}
      end)
      |> build_chart()

    datasets =
      datasets
      |> Enum.map(fn {%Bezirke.Tour.Production{title: label}, tickets_count} ->
        %{label: label, data: tickets_count}
      end)

    {production_statistics, labels, datasets}
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

  defp build_chart([]), do: {[], []}

  defp build_chart(production_statistics) do
    labels = get_labels(production_statistics)

    datasets = build_datasets(labels, production_statistics)

    {labels, datasets}
  end

  defp get_labels(production_statistics) do
    production_statistics
    |> Enum.flat_map(fn {_, sales_figures} ->
      Enum.map(sales_figures, &(DateTime.to_date(&1.record_date)))
    end)
    |> Enum.sort_by(&(&1), Date)
    |> get_labels_from_sales_figures()
  end

  defp get_labels_from_sales_figures([]), do: []

  defp get_labels_from_sales_figures(sales_figures) do
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
    |> Enum.map(fn {production, sales_figures} ->
      dataset =
        sales_figures
        |> Enum.sort_by(&(&1.record_date), DateTime)
        |> build_dataset(labels, [])
        |> Enum.reverse()

      {production, dataset}
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
