defmodule BezirkeWeb.VenueShow do
  use BezirkeWeb, :live_view

  import BezirkeWeb.LiveViewHelper

  alias Bezirke.Tour
  alias Bezirke.Venues

  def mount(%{"uuid" => uuid}, _session, socket) do
    venue = Venues.get_venue_by_uuid!(uuid)

    seasons = Tour.list_seasons()
    active_season = Tour.get_active_season(seasons)

    performances =
      venue
      |> Tour.get_performances_for_venue_and_season(active_season)
      |> Enum.sort_by(&(&1.played_at), DateTime)

    socket =
      socket
        |> assign(
          venue: venue,
          seasons: get_seasons_options(seasons),
          season_value: active_season.uuid,
          performances: performances
        )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        Venue <%= @venue.id %>
        <:subtitle>This is a venue record from your database.</:subtitle>
        <:actions>
          <.link href={~p"/venues/#{@venue}/edit"}>
            <.button>Edit venue</.button>
          </.link>
        </:actions>
      </.header>

      <.list>
        <:item title="Name"><%= @venue.name %></:item>
        <:item title="Description"><%= @venue.description %></:item>
        <:item title="Capacity"><%= @venue.capacity %></:item>
      </.list>

      <h2 class="pt-14">Performances</h2>

      <.form for={%{}} phx-change="select_season">
        <.input id="season" name="season" label="Season" type="select" options={@seasons} value={@season_value} />
      </.form>

      <ul class="mt-2">
        <li
          :for={performance <- @performances}
          phx-click={JS.navigate(~p"/performances/#{performance}?origin=venue")}
          class="flex gap-4 py-4 text-sm leading-6 sm:gap-8 hover:cursor-pointer"
        >
          <dt class="w-1/4 flex-none text-zinc-500"><%= performance.production.title %></dt>
          <dd class="text-zinc-700"><%= performance.played_at %></dd>
        </li>
      </ul>

      <div>
        <.link navigate={~p"/venues/#{@venue}/performances?season=#{@season_value}"}>
          <.button>New Performance</.button>
        </.link>
      </div>

      <.back navigate={~p"/venues"}>Back to venues</.back>
    """
  end

  def handle_event("select_season", %{"season" => season_uuid}, %{assigns: %{venue: venue}} = socket) do
    season = Tour.get_season_by_uuid!(season_uuid)

    performances =
      venue
      |> Tour.get_performances_for_venue_and_season(season)
      |> Enum.sort_by(&(&1.played_at), DateTime)

    socket =
      socket
        |> assign(
          season_value: season_uuid,
          performances: performances
        )

    {:noreply, socket}
  end
end
