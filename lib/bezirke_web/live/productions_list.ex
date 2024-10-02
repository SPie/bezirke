defmodule BezirkeWeb.ProductionsList do
  use BezirkeWeb, :live_view

  import BezirkeWeb.LiveViewHelper

  alias Bezirke.Tour

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()
    active_season = Tour.get_active_season(seasons)

    productions = Tour.get_productions_for_season(active_season)

    socket =
      socket
      |> assign(
        productions: productions,
        seasons: get_seasons_options(seasons),
        season_value: active_season.uuid
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        Listing Productions
        <:actions>
          <.link navigate={~p"/productions/new"}>
            <.button>New Production</.button>
          </.link>
        </:actions>
      </.header>

      <.form for={%{}} phx-change="select_season">
        <.input id="season" name="season" label="Season" type="select" options={@seasons} value={@season_value} />
      </.form>

      <.table id="productions" rows={@productions} row_click={&JS.navigate(~p"/productions/#{&1}")}>
        <:col :let={production} label="Title"><%= production.title %></:col>
        <:col :let={production} label="Description"><%= production.description %></:col>
        <:col :let={production} label="Season"><%= production.season.name %></:col>
        <:action :let={production}>
          <div class="sr-only">
            <.link navigate={~p"/productions/#{production}"}>Show</.link>
          </div>
          <.link navigate={~p"/productions/#{production}/edit"}>Edit</.link>
        </:action>
        <:action :let={production}>
          <.link navigate={~p"/productions/#{production}"} method="delete" data-confirm="Are you sure?">
            Delete
          </.link>
        </:action>
      </.table>
    """
  end

  def handle_event("select_season", %{"season" => season_uuid}, socket) do
    season = Tour.get_season_by_uuid!(season_uuid)

    productions = Tour.get_productions_for_season(season)

    socket =
      socket
        |> assign(
          productions: productions,
          season_value: season.uuid
        )

    {:noreply, socket}
  end
end
