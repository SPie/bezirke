defmodule BezirkeWeb.ProductionHTML do
  use BezirkeWeb, :html

  embed_templates "production_html/*"

  @doc """
  Renders a production form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def production_form(assigns)
end
