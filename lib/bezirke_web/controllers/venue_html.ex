defmodule BezirkeWeb.VenueHTML do
  use BezirkeWeb, :html

  embed_templates "venue_html/*"

  @doc """
  Renders a venue form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def venue_form(assigns)
end
