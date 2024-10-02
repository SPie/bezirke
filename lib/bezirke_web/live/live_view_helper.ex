defmodule BezirkeWeb.LiveViewHelper do
  import Phoenix.Component
  import Phoenix.LiveView

alias Bezirke.Events
  alias Bezirke.Events.Event
  alias Bezirke.Statistics
  alias Phoenix.LiveView.Components.MultiSelect.Option
  alias Phoenix.LiveView.Socket

  def get_seasons_options(seasons) do
    seasons
    |> Enum.map(fn season ->
      [
        key: season.name,
        value: season.uuid,
        selected: season.active,
      ]
    end)
  end

  def get_venues_options(venues) do
    venues
    |> Enum.map(fn venue -> [key: venue.name, value: venue.uuid] end)
  end

  def get_productions_options(productions) do
    productions
    |> Enum.map(fn production -> [key: production.title, value: production.uuid] end)
  end

  def get_event_options(events, selected_events) do
    events
    |> Enum.map(fn event ->
      Option.new(%{
        id: event.id,
        label: event.label <> " - " <> event.description,
        selected: Enum.member?(selected_events, event.id)
      })
    end)
  end

  def get_event_selection(%{"chart-events-selection" => event_selection}) do
    event_selection
    |> Enum.map(fn {key, _} -> key |> String.to_integer() end)
  end

  def get_event_selection(_), do: []

  def update_chart(socket, labels, datasets, events, use_percent, event_selection) do
    socket
    |> assign(
      labels: labels,
      datasets: datasets,
      labels: labels,
      datasets: datasets,
      use_percent: use_percent == "true",
      event_options: get_event_options(events, event_selection)
    )
    |> push_event("update-chart", %{data: %{labels: labels, datasets: datasets}})
  end

  def update_chart_events(socket, events, event_selection) do
    selected_events =
      events
      |> Enum.filter(fn %Event{id: id} -> Enum.member?(event_selection, id) end)

    socket
    |> push_event("set-chart-events", %{data: %{events: selected_events}})
  end

  def update_event_options(%Socket{assigns: %{labels: labels}} = socket, event_options) do
    events =
      event_options
      |> Enum.filter(&(&1.selected))
      |> Enum.map(&(&1.id))
      |> Events.get_by_ids()
      |> Statistics.set_event_times_boundaries(labels)

    socket
    |> push_event("set-chart-events", %{data: %{events: events}})
    |> assign(event_options: event_options)
  end

  def update_event_options(socket, _), do: socket
end
