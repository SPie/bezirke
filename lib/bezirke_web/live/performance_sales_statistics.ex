defmodule BezirkeWeb.PerformanceSalesStatistics do
  use BezirkeWeb, :live_view

  alias Bezirke.Sales
  alias Bezirke.Statistics
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
      |> Enum.map(fn {performance, sales_figures, _, _} -> {performance, sales_figures} end)
      |> Statistics.build_chart()

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
      performance.venue.name <> " " <> DateTime.to_string(performance.played_at),
      performance.sales_figures,
      performance.capacity,
      tickets_count,
    }
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
