defmodule BezirkeWeb.ProductionSalesStatistics do
  use BezirkeWeb, :live_view

  alias Bezirke.Sales
  alias Bezirke.Statistics
  alias Bezirke.Tour

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()

    {production_statistics, labels, datasets, events} =
      seasons
      |> Tour.get_active_season()
      |> get_view_data()

    socket =
      socket
      |> assign(
        seasons: get_seasons_options(seasons),
        productions_statistics: production_statistics,
        labels: labels,
        datasets: datasets,
        events: events
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        Production Sales Statistics
      </.header>
      <form>
        <.input id="season" name="season" label="Season" type="select" options={@seasons} phx-change="select_season" value=""/>
      </form>

      <div>
        <canvas
          id="production-sales"
          height="200"
          phx-hook="ChartJS"
          data-labels={Jason.encode!(@labels)}
          data-datasets={Jason.encode!(@datasets)}
          data-events={Jason.encode!(@events)}
        />
        <div>
          <%= for {production_title, _, capacity, tickets_count} <- @productions_statistics do %>
            <div>
              <h2>
                <%= production_title %>
              </h2>
              <p>
                <%= tickets_count %>
                  / <%= capacity %>
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

  def handle_event("select_season", %{"season" => season_uuid}, socket) do
    {production_statistics, labels, datasets, events} =
      season_uuid
      |> Tour.get_season_by_uuid!()
      |> get_view_data()

    socket =
      socket
      |> assign(productions_statistics: production_statistics)
      |> push_event("update-chart", %{data: %{labels: labels, datasets: datasets, events: events}})

    {:noreply, socket}
  end

  defp get_view_data(season) do
    production_statistics =
      season
      |> Tour.get_productions_for_season()
      |> Enum.map(&get_production_statistics/1)
      |> Enum.filter(fn {_, sales_figures, _, _} -> !Enum.empty?(sales_figures) end)

    {labels, datasets, events} =
      production_statistics
      |> Enum.map(fn {production, sales_figures, _, _} -> {production, sales_figures} end)
      |> Statistics.build_chart()

    {production_statistics, labels, datasets, events}
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

    {
      production.title,
      sales_figures,
      capacity,
      tickets_count,
    }
  end
end
