defmodule BezirkeWeb.StatisticsLiveViewHelper do
  alias Phoenix.LiveView.Components.MultiSelect.Option

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

  def get_event_selection(nil), do: []

  def get_event_selection(selected_options) do
    selected_options
    |> Enum.map(fn {key, _} -> key |> String.to_integer() end)
  end
end
