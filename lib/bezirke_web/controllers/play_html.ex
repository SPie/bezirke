defmodule BezirkeWeb.PlayHTML do
  use BezirkeWeb, :html

  embed_templates "play_html/*"

  @doc """
  Renders a play form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def play_form(assigns)
end
