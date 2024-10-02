defmodule BezirkeWeb.PerformanceHTML do
  use BezirkeWeb, :html

  embed_templates "performance_html/*"

  @doc """
  Renders a performance form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :production, Bezirke.Tour.Production, required: false, default: nil
  attr :edit, :boolean, default: false

  def performance_form(assigns)

  def venues_list(changeset) do
    venue_uuid = Ecto.Changeset.get_change(changeset, :venue_uuid)

    Bezirke.Venues.list_venues()
    |> Enum.map(fn venue -> [key: venue.name, value: venue.uuid, selected: venue.uuid == venue_uuid] end)
  end
end
