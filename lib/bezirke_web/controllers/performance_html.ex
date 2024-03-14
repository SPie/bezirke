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

  def venues_list(changeset) do
    venue_uuid = Ecto.Changeset.get_change(changeset, :venue_uuid)

    Bezirke.Venues.list_venues()
    |> Enum.map(fn venue -> [key: venue.name, value: venue.uuid, selected: venue.uuid == venue_uuid] end)
  end
end
