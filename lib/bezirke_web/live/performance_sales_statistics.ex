defmodule BezirkeWeb.PerformanceSalesStatistics do
  alias Bezirke.Statistics.StatisticsData
  use BezirkeWeb, :live_view

  import BezirkeWeb.LiveViewHelper

  alias Bezirke.Sales
  alias Bezirke.Statistics
  alias Bezirke.Tour
  alias Phoenix.LiveView.Components.MultiSelect

  def render(assigns) do
    ~H"""
      <.header>
        Performance Sales Statistics
      </.header>
      <.form :let={f} for={%{}} phx-change="select_production">
        <.input id="season" name="season" label="Season" type="select" options={@seasons} value={@season_value} />
        <.input id="production" name="production" label="Production" type="select" options={@productions} value={@production_value} />
        <.input id="use-percent" name="use-percent" label="in percent" type="checkbox" checked={@use_percent} value="true" />
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
            label: performance,
            capacity: capacity,
            tickets_count: tickets_count,
            subscribers_quantity: subscribers_quantity
          } <- @performance_statisctics do %>
            <div>
              <h2><%= performance %></h2>
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

    active_season = Tour.get_active_season(seasons)

    productions = Tour.get_productions_for_season(active_season)

    active_production = List.first(productions)

    {performance_statisctics, datasets, events} = get_view_data(active_production, false, true)

    socket =
      socket
      |> assign(
        seasons: get_seasons_options(seasons),
        productions: get_productions_options(productions),
        season_value: active_season.uuid,
        production_value: if active_production do active_production.uuid end,
        performance_statisctics: performance_statisctics,
        datasets: datasets,
        event_options: get_event_options(events, []),
        use_percent: false,
        with_subscribers: true
      )

    {:ok, socket}
  end

  def handle_event(
    "select_production",
    %{
      "_target" => ["use-percent"],
      "season" => season_uuid,
      "production" => production_uuid,
      "use-percent" => use_percent,
      "with-subscribers" => with_subscribers?
    } = params,
    socket
  ) do
    active_season = Tour.get_season_by_uuid!(season_uuid)

    productions = Tour.get_productions_for_season(active_season)

    active_production =
      productions
      |> Enum.find(&(&1.uuid == production_uuid))
      |> case do
        nil -> List.first(productions)
        production -> production
      end

    {performance_statisctics, datasets, events} = get_view_data(active_production, use_percent, with_subscribers?)

    event_selection = get_event_selection(params)

    socket =
      socket
      |> assign(
        productions: get_productions_options(productions),
        season_value: season_uuid,
        production_value: production_uuid,
        with_subscribers: with_subscribers? == true || with_subscribers? == "true",
        performance_statisctics: performance_statisctics
      )
      |> update_chart(datasets, events, use_percent, event_selection)
      |> update_chart_events(events, event_selection)

    {:noreply, socket}
  end

  def handle_event(
    "select_production",
    %{
      "season" => season_uuid,
      "production" => production_uuid,
      "use-percent" => use_percent,
      "with-subscribers" => with_subscribers?
    },
    socket
  ) do
    active_season = Tour.get_season_by_uuid!(season_uuid)

    productions = Tour.get_productions_for_season(active_season)

    active_production =
      productions
      |> Enum.find(&(&1.uuid == production_uuid))
      |> case do
        nil -> List.first(productions)
        production -> production
      end

    {performance_statisctics, datasets, events} = get_view_data(active_production, use_percent, with_subscribers?)

    socket =
      socket
      |> assign(
        productions: get_productions_options(productions),
        season_value: season_uuid,
        production_value: production_uuid,
        with_subscribers: with_subscribers? == true || with_subscribers? == "true",
        performance_statisctics: performance_statisctics
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

  defp get_view_data(nil, _, _), do: {[], [], []}

  defp get_view_data(production, use_percent, with_subscribers?) do
    performance_statisctics =
      production
      |> Tour.get_performances_for_production_with_sales_figures()
      |> Enum.filter(fn performance -> is_nil(performance.cancelled_at) end)
      |> Enum.map(fn performance -> get_performance_statistics(performance, production, with_subscribers?) end)
      |> Enum.filter(fn %StatisticsData{sales_figures: sales_figures} -> !Enum.empty?(sales_figures) end)

    {datasets, events} =
      performance_statisctics
      |> Statistics.build_sales_chart(use_percent, with_subscribers?)

    {performance_statisctics, datasets, events}
  end

  defp get_performance_statistics(performance, production, with_subscribers?) do
    subscribers_quantity = case Tour.get_subscriber_for_venue_and_season(performance.venue, production.season) do
      nil -> 0
      subscriber -> subscriber.quantity
    end

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
      label: performance.venue.name <> " " <> Bezirke.DateTime.format_datetime(performance.played_at),
      sales_figures: performance.sales_figures,
      capacity: performance.capacity,
      tickets_count: tickets_count,
      subscribers_quantity: subscribers_quantity
    }
  end
end
