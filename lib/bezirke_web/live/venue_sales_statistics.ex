defmodule BezirkeWeb.VenueSalesStatistics do
  alias Bezirke.Statistics.StatisticsData
  use BezirkeWeb, :live_view

  import BezirkeWeb.LiveViewHelper

  alias Bezirke.Sales
  alias Bezirke.Statistics
  alias Bezirke.Tour
  alias Bezirke.Venues
  alias Phoenix.LiveView.Components.MultiSelect

  def render(assigns) do
    ~H"""
      <.header>
        Venue Sales Statistics
      </.header>
      <.form :let={f} for={%{}} phx-change="select_venue">
        <.input id="season" name="season" label="Season" type="select" options={@seasons} value={@season_value}/>
        <.input id="venue" name="venue" label="Venue" type="select" options={@venues} value={@venue_value}/>
        <.input id="use-percent" name="use-percent" label="in percent" type="checkbox" checked={@use_percent} />
        <.input id="with-subscribers" name="with-subscribers" label="with subscribers" type="checkbox" checked={@with_subscribers} />
      </.form>

      <div class="relative">
        <div class="relative z-10">
          <.form :let={f} for={%{}} phx-change="select_season">
            <MultiSelect.multi_select
              id="chart-events-selection"
              form={f}
              options={@event_options}
              on_change={fn opts -> send(self(), {:updated_options, opts}) end}
            />
          </.form>
        </div>

        <div>
          <div
            id="production-sales"
            phx-hook="Chart"
            phx-update="ignore"
            class="w-full h-[40rem]"
            data-datasets={Jason.encode!(@datasets)}
          ></div>

        </div>
        <div>
          <%= for %StatisticsData{
            label: performance_title,
            capacity: capacity,
            tickets_count: tickets_count,
            subscribers_quantity: subscribers_quantity
          } <- @performance_statistics do %>
            <div>
              <h2>
                <%= performance_title %>
              </h2>
              <p>
                <%= tickets_count %>(<%= subscribers_quantity %>) / <%= capacity %>
                  (<%=  tickets_count / capacity * 100 |> Decimal.from_float() |> Decimal.round(2) %> %)
              </p>
            </div>
          <% end %>
        </div>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()

    active_season =
      seasons
      |> Tour.get_active_season()

    venues = Venues.get_venues_for_season(active_season)
    active_venue = venues |> List.first()

    {performance_statistics, datasets, events} =
      venues
      |> List.first()
      |> get_view_data(active_season, false, true)

    socket =
      socket
      |> assign(
        seasons: get_seasons_options(seasons),
        venues: get_venues_options(venues),
        season_value: active_season.uuid,
        venue_value: if active_venue do active_venue.uuid end,
        performance_statistics: performance_statistics,
        datasets: datasets,
        event_options: get_event_options(events, []),
        use_percent: false,
        with_subscribers: true
      )

    {:ok, socket}
  end

  def handle_event(
    "select_venue",
    %{
      "_target" => ["use-percent"],
      "season" => season_uuid,
      "venue" => venue_uuid,
      "use-percent" => use_percent,
      "with-subscribers" => with_subscribers?
    } = params,
    socket
  ) do
    active_season = Tour.get_season_by_uuid!(season_uuid)

    venues = Venues.get_venues_for_season(active_season)

    {performance_statistics, datasets, events} =
      venues
      |> Enum.find(&(&1.uuid == venue_uuid))
      |> case do
        nil -> List.first(venues)
        venue -> venue
      end
      |> get_view_data(active_season, use_percent, with_subscribers?)

    event_selection = get_event_selection(params)

    socket =
      socket
      |> assign(
        venues: get_venues_options(venues),
        season_value: season_uuid,
        venue_value: venue_uuid,
        with_subscribers: with_subscribers? == true || with_subscribers? == "true",
        performance_statistics: performance_statistics
      )
      |> update_chart(datasets, events, use_percent, event_selection)
      |> update_chart_events(events, event_selection)

    {:noreply, socket}
  end

  def handle_event(
    "select_venue",
    %{
      "season" => season_uuid,
      "venue" => venue_uuid,
      "use-percent" => use_percent,
      "with-subscribers" => with_subscribers?
    },
    socket
  ) do
    active_season = Tour.get_season_by_uuid!(season_uuid)

    venues = Venues.get_venues_for_season(active_season)

    {performance_statistics, datasets, events} =
      venues
      |> Enum.find(&(&1.uuid == venue_uuid))
      |> case do
        nil -> List.first(venues)
        venue -> venue
      end
      |> get_view_data(active_season, use_percent, with_subscribers?)

    socket =
      socket
      |> assign(
        venues: get_venues_options(venues),
        season_value: season_uuid,
        venue_value: venue_uuid,
        with_subscribers: with_subscribers? == true || with_subscribers? == "true",
        performance_statistics: performance_statistics
      )
      |> update_chart(datasets, events, use_percent, [])

    {:noreply, socket}
  end

  def handle_info({:updated_options, event_options}, socket) do
    socket =
      socket
      |> update_event_options(event_options)

    {:noreply, socket}
  end

  defp get_view_data(nil, _, _, _), do: {[], [], []}

  defp get_view_data(venue, season, use_percent, with_subscribers?) do
    subscribers_quantity = case Tour.get_subscriber_for_venue_and_season(venue, season) do
      nil -> 0
      subscriber -> subscriber.quantity
    end

    performance_statistics =
      venue
      |> Tour.get_performances_for_venue_and_season_with_sales_figures(season)
      |> Enum.filter(fn performance -> is_nil(performance.cancelled_at) end)
      |> Enum.map(fn performance -> get_performance_statistics(performance, subscribers_quantity, with_subscribers?) end)
      |> Enum.filter(fn %StatisticsData{sales_figures: sales_figures} -> !Enum.empty?(sales_figures) end)

    {datasets, events} =
      performance_statistics
      |> Statistics.build_sales_chart(use_percent, with_subscribers?)

    {performance_statistics, datasets, events}
  end

  defp get_performance_statistics(performance, subscribers_quantity, with_subscribers?) do
    tickets_count =
      performance.sales_figures
      |> Enum.reduce(
        0,
        fn %Sales.SalesFigures{tickets_count: tickets_count}, total_tickets_count ->
          total_tickets_count + tickets_count
        end
      )

    tickets_count = cond do
      with_subscribers? == false || with_subscribers? == "false" ->
        max(tickets_count - subscribers_quantity, 0)
      true -> tickets_count
    end

    %StatisticsData{
      label: performance.production.title <> " " <> Bezirke.DateTime.format_datetime(performance.played_at),
      sales_figures: performance.sales_figures,
      capacity: performance.capacity,
      tickets_count: tickets_count,
      subscribers_quantity: subscribers_quantity
    }
  end
end
