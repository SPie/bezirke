defmodule BezirkeWeb.ProductionSalesStatistics do
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
        Production Sales Statistics
      </.header>
      <.form for={%{}} phx-change="select_season">
        <.input id="season" name="season" label="Season" type="select" options={@seasons} value={@season_value} />
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
            label: production_title,
            capacity: capacity,
            tickets_count: tickets_count,
            subscribers_quantity: subscribers_quantity
          } <- @productions_statistics do %>
            <div>
              <h2>
                <%= production_title %>
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

    {production_statistics, datasets, events} = get_view_data(active_season, false, true)

    socket =
      socket
      |> assign(
        season_value: active_season.uuid,
        seasons: get_seasons_options(seasons),
        productions_statistics: production_statistics,
        datasets: datasets,
        event_options: get_event_options(events, []),
        use_percent: false,
        with_subscribers: true
      )

    {:ok, socket}
  end

  def handle_event(
    "select_season",
    %{
      "_target" => ["use-percent"],
      "season" => season_uuid,
      "use-percent" => use_percent?,
      "with-subscribers" => with_subscribers?
    } = params,
    socket
  ) do
    {production_statistics, datasets, events} =
      season_uuid
      |> Tour.get_season_by_uuid!()
      |> get_view_data(use_percent?, with_subscribers?)

    event_selection = get_event_selection(params)

    socket =
      socket
      |> assign(
        season_value: season_uuid,
        with_subscribers: with_subscribers? == "true",
        production_statistics: production_statistics
      )
      |> update_chart(datasets, events, use_percent?, event_selection)
      |> update_chart_events(events, event_selection)

    {:noreply, socket}
  end

  def handle_event("select_season", %{"season" => season_uuid, "use-percent" => use_percent?, "with-subscribers" => with_subscribers?}, socket) do
    {production_statistics, datasets, events} =
      season_uuid
      |> Tour.get_season_by_uuid!()
      |> get_view_data(use_percent?, with_subscribers?)

    socket =
      socket
      |> assign(
        season_value: season_uuid,
        with_subscribers: with_subscribers? == "true",
        productions_statistics: production_statistics
      )
      |> update_chart(datasets, events, use_percent?, [])

    {:noreply, socket}
  end

  def handle_info({:updated_options, event_options}, socket) do
    socket =
      socket
      |> update_event_options(event_options)

    {:noreply, socket}
  end

  defp get_view_data(season, use_percent?, with_subscribers?) do
    total_subscribers = Tour.get_total_subscribers_for_season(season)

    production_statistics =
      season
      |> Tour.get_productions_for_season()
      |> Enum.map(fn production ->
        get_production_statistics(production, total_subscribers, with_subscribers?)
      end)
      |> Enum.filter(fn %StatisticsData{sales_figures: sales_figures} -> !Enum.empty?(sales_figures) end)

    {datasets, events} =
      production_statistics
      |> Statistics.build_sales_chart(use_percent?, with_subscribers?)

    {production_statistics, datasets, events}
  end

  defp get_production_statistics(production, total_subscribers, with_subscribers?) do
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

    tickets_count = cond do
      with_subscribers? == false || with_subscribers? == "false" ->
        max(tickets_count - total_subscribers, 0)
      true -> tickets_count
    end

    %StatisticsData{
      label: production.title,
      sales_figures: sales_figures,
      capacity: capacity,
      tickets_count: tickets_count,
      subscribers_quantity: total_subscribers
    }
  end
end
