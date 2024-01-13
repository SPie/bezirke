defmodule BezirkeWeb.SeasonHTML do
  use BezirkeWeb, :html

  embed_templates "season_html/*"

  @doc """
  Renders a season form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def season_form(assigns)
end
