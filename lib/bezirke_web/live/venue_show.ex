defmodule BezirkeWeb.VenueShow do
  use BezirkeWeb, :live_view

  alias Bezirke.Tour
  alias Bezirke.Venues

  def mount(%{"uuid" => uuid} = params, _session, socket) do
    venue = Venues.get_venue_by_uuid!(uuid)

    performances =
      venue
      |> Tour.get_performances_for_venue()
      |> Enum.sort_by(&(&1.played_at), DateTime)

    socket =
      socket
        |> assign(
          venue: venue,
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
        <.link href={~p"/venues/#{@venue}/performances/new"}>
          <.button>New Performance</.button>
        </.link>
      </div>

      <.back navigate={~p"/venues"}>Back to venues</.back>
    """
  end
end
