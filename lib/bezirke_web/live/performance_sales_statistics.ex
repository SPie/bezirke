defmodule BezirkeWeb.PerformanceSalesStatistics do
  use BezirkeWeb, :live_view

  alias Bezirke.Sales
  alias Bezirke.Tour

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()

    productions =
      seasons
      |> Tour.get_active_season()
      |> Tour.get_productions_for_season()

    {performance_statisctics, labels, datasets} =
      productions
      |> List.first()
      |> get_view_data()

    socket =
      socket
      |> assign(seasons: get_seasons_options(seasons))
      |> assign(productions: get_productions_options(productions))
      |> assign(performance_statisctics: performance_statisctics)
      |> assign(labels: labels)
      |> assign(datasets: datasets)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        Performance Sales Statistics
      </.header>
      <.form>
        <.input id="season" name="season" label="Season" type="select" options={@seasons} phx-change="select_season" value=""/>
        <.input id="production" name="production" label="Production" type="select" options={@productions} phx-change="select_production" value=""/>
      </.form>
      <div>
        <%= for {performance, sales_figures, capacity, tickets_count} <- @performance_statisctics do %>
          <div>
            <h2><%= performance %></h2>
            <p>
              <%= tickets_count %> / <%= capacity %>
              (<%=  tickets_count / capacity * 100
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
    productions =
      season_uuid
      |> Tour.get_season_by_uuid!()
      |> Tour.get_productions_for_season()

    {performance_statisctics, labels, datasets} =
      productions
      |> List.first()
      |> get_view_data()

    socket =
      socket
      |> assign(productions: get_productions_options(productions))
      |> assign(performance_statisctics: performance_statisctics)
      |> push_event("update-chart", %{labels: labels, datasets: datasets})

    {:noreply, socket}
  end

  def handle_event("select_production", %{"production" => production_uuid}, socket) do
    {performance_statisctics, labels, datasets} =
      production_uuid
      |> Tour.get_production_by_uuid!()
      |> get_view_data()

    socket =
      socket
      |> assign(performance_statisctics: performance_statisctics)
      |> push_event("update-chart", %{labels: labels, datasets: datasets})

    {:noreply, socket}
  end

  defp get_view_data(production) do
    performance_statisctics =
      production
      |> Tour.get_performances_for_production_with_sales_figures()
      |> Enum.map(&get_performance_statistics/1)
      |> Enum.filter(fn {_, sales_figures, _, _} -> !Enum.empty?(sales_figures) end)

    {labels, datasets} =
      performance_statisctics
      |> build_chart()

    datasets =
      datasets
      |> Enum.map(fn {label, tickets_count} ->
        %{label: label, data: tickets_count}
      end)

    {performance_statisctics, labels, datasets}
  end

  defp get_performance_statistics(performance) do
    tickets_count =
      performance.sales_figures
      |> Enum.reduce(
        0,
        fn %Sales.SalesFigures{tickets_count: tickets_count}, total_tickets_count ->
          total_tickets_count + tickets_count
        end
      )

    {
      performance.venue.name,
      performance.sales_figures,
      performance.capacity,
      tickets_count,
    }
  end

  defp build_chart([]), do: {[], []}

  defp build_chart(performance_statistics) do
    labels = get_labels(performance_statistics)

    datasets = build_datasets(labels, performance_statistics)

    {labels, datasets}
  end

  defp get_labels(performance_statistics) do
    performance_statistics
    |> Enum.flat_map(fn {_, sales_figures, _, _} ->
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

  defp build_datasets(labels, performance_statistics) do
    performance_statistics
    |> Enum.map(fn {performance, sales_figures, _, _} ->
      dataset =
        sales_figures
        |> Enum.sort_by(&(&1.record_date), DateTime)
        |> build_dataset(labels, [])
        |> Enum.reverse()

      {performance, dataset}
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

  defp get_productions_options(productions) do
    productions
    |> Enum.map(fn production -> [key: production.title, value: production.uuid] end)
  end
end
