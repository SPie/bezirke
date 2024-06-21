defmodule BezirkeWeb.VenueSalesStatistics do
  use BezirkeWeb, :live_view

  import BezirkeWeb.StatisticsLiveViewHelper

  alias Bezirke.Events
  alias Bezirke.Events.Event
  alias Bezirke.Sales
  alias Bezirke.Statistics
  alias Bezirke.Tour
  alias Bezirke.Venues
  alias Phoenix.LiveView.Components.MultiSelect

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()

    active_season =
      seasons
      |> Tour.get_active_season()

    venues = Venues.get_venues_for_season(active_season)
    active_venue = venues |> List.first()

    {performance_statistics, labels, datasets, events} =
      venues
      |> List.first()
      |> get_view_data(active_season, false)

    socket =
      socket
      |> assign(
        seasons: get_seasons_options(seasons),
        venues: get_venues_options(venues),
        season_value: active_season.uuid,
        venue_value: if active_venue do active_venue.uuid end,
        performance_statistics: performance_statistics,
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
        Venue Sales Statistics
      </.header>
      <.form :let={f} for={%{}} phx-change="select_venue">
        <.input id="season" name="season" label="Season" type="select" options={@seasons} value={@season_value}/>
        <.input id="venue" name="venue" label="Venue" type="select" options={@venues} value={@venue_value}/>
        <.input id="use-percent" name="use-percent" label="in percent" type="checkbox" checked={@use_percent} />
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
          <%= for {performance_title, _, capacity, tickets_count} <- @performance_statistics do %>
            <div>
              <h2>
                <%= performance_title %>
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

  def handle_event(
    "select_venue",
    %{
      "_target" => ["use-percent"],
      "season" => season_uuid,
      "venue" => venue_uuid,
      "use-percent" => use_percent
    } = params,
    socket
  ) do
    active_season = Tour.get_season_by_uuid!(season_uuid)

    venues = Venues.get_venues_for_season(active_season)

    {performance_statistics, labels, datasets, events} =
      venues
      |> Enum.find(&(&1.uuid == venue_uuid))
      |> case do
        nil -> List.first(venues)
        venue -> venue
      end
      |> get_view_data(active_season, use_percent)

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
        venues: get_venues_options(venues),
        season_value: season_uuid,
        venue_value: venue_uuid,
        performance_statistics: performance_statistics,
        use_percent: use_percent == "true",
        event_options: get_event_options(events, event_selection)
      )
      |> push_event("update-chart", %{data: %{labels: labels, datasets: datasets, events: events}})
      |> push_event("set-chart-events", %{data: %{events: selected_events}})

    {:noreply, socket}
  end

  def handle_event("select_venue", %{"season" => season_uuid, "venue" => venue_uuid, "use-percent" => use_percent}, socket) do
    active_season = Tour.get_season_by_uuid!(season_uuid)

    venues = Venues.get_venues_for_season(active_season)

    {performance_statistics, labels, datasets, events} =
      venues
      |> Enum.find(&(&1.uuid == venue_uuid))
      |> case do
        nil -> List.first(venues)
        venue -> venue
      end
      |> get_view_data(active_season, use_percent)

    socket =
      socket
      |> assign(
        venues: get_venues_options(venues),
        season_value: season_uuid,
        venue_value: venue_uuid,
        performance_statistics: performance_statistics,
        use_percent: use_percent == "true",
        event_options: get_event_options(events, [])
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

  defp get_view_data(venue, season, use_percent) do
    performance_statistics =
      venue
      |> Tour.get_performances_for_venue_and_season_with_sales_figures(season)
      |> Enum.map(&get_performance_statistics/1)
      |> Enum.filter(fn {_, sales_figures, _, _} -> !Enum.empty?(sales_figures) end)

    {labels, datasets, events} =
      performance_statistics
      |> Enum.map(fn {performance, sales_figures, capacity, _} -> {performance, sales_figures, capacity} end)
      |> Statistics.build_chart(use_percent)

    {performance_statistics, labels, datasets, events}
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
      performance.production.title <> " " <> Bezirke.DateTime.format_datetime(performance.played_at),
      performance.sales_figures,
      performance.capacity,
      tickets_count,
    }
  end
end
