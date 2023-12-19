defmodule BezirkeWeb.PerformanceHTML do
  use BezirkeWeb, :html

  embed_templates "performance_html/*"

  @doc """
  Renders a performance form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def performance_form(assigns)

  def productions_list(_changeset) do
  # get production from performance
    for production <- Bezirke.Tour.list_productions() do
      [key: production.title, value: production.uuid]
    end
  end

  def venues_list(_changeset) do
    # get venue from performance
    for venue <- Bezirke.Venues.list_venues() do
      [key: venue.name, value: venue.uuid]
    end
  end
end
