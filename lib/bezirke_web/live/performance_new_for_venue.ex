defmodule BezirkeWeb.PerformanceNewForVenue do
  use BezirkeWeb, :live_view

  import BezirkeWeb.LiveViewHelper

  alias Bezirke.Tour
  alias Bezirke.Tour.Performance
  alias Bezirke.Venues

  def mount(%{"venue_uuid" => venue_uuid} = params, _session, socket) do
    changeset = Tour.change_performance(%Performance{})

    venue = Venues.get_venue_by_uuid!(venue_uuid)

    seasons = Tour.list_seasons()
    active_season = case Map.get(params, "season") do
      nil -> Tour.get_active_season(seasons)
      season_uuid -> Tour.get_season_by_uuid!(season_uuid)
    end

    productions = Tour.get_productions_for_season(active_season)

    socket =
      socket
      |> assign(
        changeset: changeset,
        seasons: get_seasons_options(seasons),
        season_value: active_season.uuid,
        productions: get_productions_options(productions),
        venue: venue
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        New Performance for <%= @venue.name %>
      </.header>

      <.form :let={f} for={@changeset} phx-submit="save">
        <div class="mt-10 space-y-8 bg-white">
          <.error :if={@changeset.action}>
            Oops, something went wrong! Please check the errors below.
          </.error>
          <.input field={f[:played_at_date]} type="date" label="Played at" />
          <.input field={f[:played_at_time]} type="time" />
          <.input field={f[:capacity]} type="number" label="Capacity" />
          <.input id="season" name="season" label="Season" type="select" options={@seasons} value={@season_value} phx-change="select_season" />
          <.input label="Production" field={f[:production_uuid]} type="select" options={@productions} />

          <div class="mt-2 flex items-center justify-between gap-6">
            <.button>Save Performance</.button>
          </div>
        </div>
      </.form>

      <.back navigate={~p"/venues/#{@venue}"}>Back to venue</.back>
    """
  end

  def handle_event("select_season", %{"season" => season_uuid}, socket) do
    productions =
      season_uuid
      |> Tour.get_season_by_uuid!()
      |> Tour.get_productions_for_season()
      |> get_productions_options()

    socket =
      socket
      |> assign(
        productions: productions,
        season_value: season_uuid
      )

    {:noreply, socket}
  end

  def handle_event("save", %{"performance" => performance_params}, %{assigns: %{venue: venue}} = socket) do
    Tour.create_performance({:venue, venue.uuid}, performance_params)
    |> handle_create_performance_response(socket)
  end

  defp handle_create_performance_response({:ok, performance}, socket) do
    socket =
      socket
      |> put_flash(:info, "Performance created successfully.")
      |> redirect(to: ~p"/performances/#{performance}?origin=venue")

    {:noreply, socket}
  end

  defp handle_create_performance_response({:error, changeset}, %{assigns: %{venue: venue}} = socket) do
    socket =
      socket
      |> assign(
        venue: venue,
        changeset: changeset
      )

    {:noreply, socket}
  end
end
