defmodule BezirkeWeb.PerformanceHTML do
  use BezirkeWeb, :html

  embed_templates "performance_html/*"

  @doc """
  Renders a performance form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def performance_form(assigns)

  def productions_list(changeset) do
    production_uuid = Ecto.Changeset.get_change(changeset, :production_uuid)

    for production <- Bezirke.Tour.list_productions() do
      [
        key: production.title,
        value: production.uuid,
        selected: production.uuid == production_uuid,
      ]
    end
  end

  def venues_list(changeset) do
    venue_uuid = Ecto.Changeset.get_change(changeset, :venue_uuid)

    for venue <- Bezirke.Venues.list_venues() do
      [key: venue.name, value: venue.uuid, selected: venue.uuid == venue_uuid]
    end
  end
end
