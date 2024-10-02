defmodule BezirkeWeb.PerformanceNewForVenue do
  use BezirkeWeb, :live_view

  import BezirkeWeb.LiveViewHelper

  alias Bezirke.Tour
  alias Bezirke.Tour.Performance
  alias Bezirke.Venues

  def mount(%{"venue_uuid" => venue_uuid}, _session, socket) do
    changeset = Tour.change_performance(%Performance{})

    venue = Venues.get_venue_by_uuid!(venue_uuid)

    socket =
      socket
      |> assign(
        changeset: changeset,
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
          <.input field={f[:production_uuid]} type="select" options={productions_list(@changeset)} />

          <div class="mt-2 flex items-center justify-between gap-6">
            <.button>Save Performance</.button>
          </div>
        </div>
      </.form>

      <.back navigate={~p"/venues/#{@venue}"}>Back to venue</.back>
    """
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

  def productions_list(changeset) do
    production_uuid = Ecto.Changeset.get_change(changeset, :production_uuid)

    Bezirke.Tour.list_productions()
    |> Enum.map(fn production -> [
        key: production.title,
        value: production.uuid,
        selected: production.uuid == production_uuid,
      ]
    end)
  end
end
