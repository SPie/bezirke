defmodule BezirkeWeb.PerformanceSalesStatistics do
  use BezirkeWeb, :live_view

  alias Bezirke.Sales
  alias Bezirke.Statistics
  alias Bezirke.Tour

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()

    active_season = Tour.get_active_season(seasons)

    productions = Tour.get_productions_for_season(active_season)

    active_production = List.first(productions)

    {performance_statisctics, labels, datasets} = get_view_data(active_production)

    socket =
      socket
      |> assign(
        seasons: get_seasons_options(seasons),
        productions: get_productions_options(productions),
        season_value: active_season.uuid,
        production_value: if active_production do active_production.uuid end,
        performance_statisctics: performance_statisctics,
        labels: labels,
        datasets: datasets
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        Performance Sales Statistics
      </.header>
      <form phx-change="select_production">
        <.input id="season" name="season" label="Season" type="select" options={@seasons} value={@season_value} />
        <.input id="production" name="production" label="Production" type="select" options={@productions} value={@production_value} />
      </form>
      <div>
        <div>
          <canvas
            id="production-sales"
            phx-hook="ChartJS"
            data-labels={Jason.encode!(@labels)}
            data-datasets={Jason.encode!(@datasets)}
          />
        </div>
        <div>
          <%= for {performance, _, capacity, tickets_count} <- @performance_statisctics do %>
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
        </div>
      </div>
    """
  end

  def handle_event("select_production", %{"season" => season_uuid, "production" => production_uuid}, socket) do
    active_season = Tour.get_season_by_uuid!(season_uuid)

    productions = Tour.get_productions_for_season(active_season)

    active_production =
      productions
      |> Enum.find(&(&1.uuid == production_uuid))
      |> case do
        nil -> List.first(productions)
        production -> production
      end

    {performance_statisctics, labels, datasets} = get_view_data(active_production)

    socket =
      socket
      |> assign(
        productions: get_productions_options(productions),
        season_value: season_uuid,
        production_value: production_uuid,
        performance_statisctics: performance_statisctics
      )
      |> push_event("update-chart", %{labels: labels, datasets: datasets})

    {:noreply, socket}
  end

  defp get_view_data(nil), do: {[], [], []}

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
    |> Enum.map(fn season -> [key: season.name, value: season.uuid] end)
  end

  defp get_productions_options(productions) do
    productions
    |> Enum.map(fn production -> [key: production.title, value: production.uuid] end)
  end
end
