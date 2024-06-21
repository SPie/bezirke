defmodule BezirkeWeb.PerformanceSalesStatistics do
  use BezirkeWeb, :live_view

  import BezirkeWeb.StatisticsLiveViewHelper

  alias Bezirke.Events
  alias Bezirke.Events.Event
  alias Bezirke.Sales
  alias Bezirke.Statistics
  alias Bezirke.Tour
  alias Phoenix.LiveView.Components.MultiSelect

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()

    active_season = Tour.get_active_season(seasons)

    productions = Tour.get_productions_for_season(active_season)

    active_production = List.first(productions)

    {performance_statisctics, labels, datasets, events} = get_view_data(active_production, false)

    socket =
      socket
      |> assign(
        seasons: get_seasons_options(seasons),
        productions: get_productions_options(productions),
        season_value: active_season.uuid,
        production_value: if active_production do active_production.uuid end,
        performance_statisctics: performance_statisctics,
        labels: labels,
        datasets: datasets,
        event_options: get_event_options(events, []),
        use_percent: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        Performance Sales Statistics
      </.header>
      <% @use_percent |> IO.inspect() %>
      <.form :let={f} for={%{}} phx-change="select_production">
        <.input id="season" name="season" label="Season" type="select" options={@seasons} value={@season_value} />
        <.input id="production" name="production" label="Production" type="select" options={@productions} value={@production_value} />
        <.input id="use-percent" name="use-percent" label="in percent" type="checkbox" checked={@use_percent} value="true" />
        <MultiSelect.multi_select
          id="chart-events-selection"
          form={f}
          options={@event_options}
          on_change={fn opts -> send(self(), {:updated_options, opts}) end}
        />
      </.form>
      <div>
        <canvas
          id="production-sales"
          height="200"
          phx-hook="ChartJS"
          data-labels={Jason.encode!(@labels)}
          data-datasets={Jason.encode!(@datasets)}
        />
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

  def handle_event(
    "select_production",
    %{
      "_target" => ["use-percent"],
      "season" => season_uuid,
      "production" => production_uuid,
      "use-percent" => use_percent
    } = params,
    socket
  ) do
    use_percent |> IO.inspect()
    active_season = Tour.get_season_by_uuid!(season_uuid)

    productions = Tour.get_productions_for_season(active_season)

    active_production =
      productions
      |> Enum.find(&(&1.uuid == production_uuid))
      |> case do
        nil -> List.first(productions)
        production -> production
      end

    {performance_statisctics, labels, datasets, events} = get_view_data(active_production, use_percent)

    event_selection =
      params
      |> Map.get("chart-events-selection")
      |> get_event_selection()

    selected_events =
      events
      |> Enum.filter(fn %Event{id: id} -> Enum.member?(event_selection, id) end)

    socket =
      socket
      |> assign(
        productions: get_productions_options(productions),
        season_value: season_uuid,
        production_value: production_uuid,
        performance_statisctics: performance_statisctics,
        use_percent: use_percent == "true",
        event_options: get_event_options(events, event_selection)
      )
      |> push_event("update-chart", %{data: %{labels: labels, datasets: datasets, events: events}})
      |> push_event("set-chart-events", %{data: %{events: selected_events}})

    {:noreply, socket}
  end

  def handle_event("select_production", %{"season" => season_uuid, "production" => production_uuid, "use-percent" => use_percent}, socket) do
    use_percent |> IO.inspect()
    active_season = Tour.get_season_by_uuid!(season_uuid)

    productions = Tour.get_productions_for_season(active_season)

    active_production =
      productions
      |> Enum.find(&(&1.uuid == production_uuid))
      |> case do
        nil -> List.first(productions)
        production -> production
      end

    {performance_statisctics, labels, datasets, events} = get_view_data(active_production, use_percent)

    socket =
      socket
      |> assign(
        productions: get_productions_options(productions),
        season_value: season_uuid,
        production_value: production_uuid,
        performance_statisctics: performance_statisctics,
        use_percent: use_percent == "true"
      )
      |> push_event("update-chart", %{data: %{labels: labels, datasets: datasets, events: events}})

    {:noreply, socket}
  end

  def handle_info({:updated_options, event_options}, socket) do
    events =
      event_options
      |> Enum.filter(&(&1.selected))
      |> Enum.map(&(&1.id))
      |> Events.get_by_ids()

    socket =
      socket
      |> push_event("set-chart-events", %{data: %{events: events}})
      |> assign(event_options: event_options)

    {:noreply, socket}
  end

  defp get_view_data(nil, _), do: {[], [], []}

  defp get_view_data(production, use_percent) do
    performance_statisctics =
      production
      |> Tour.get_performances_for_production_with_sales_figures()
      |> Enum.map(&get_performance_statistics/1)
      |> Enum.filter(fn {_, sales_figures, _, _} -> !Enum.empty?(sales_figures) end)

    {labels, datasets, events} =
      performance_statisctics
      |> Enum.map(fn {performance, sales_figures, capacity, _} -> {performance, sales_figures, capacity} end)
      |> Statistics.build_chart(use_percent)

    {performance_statisctics, labels, datasets, events}
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
      performance.venue.name <> " " <> Bezirke.DateTime.format_datetime(performance.played_at),
      performance.sales_figures,
      performance.capacity,
      tickets_count,
    }
  end
end
