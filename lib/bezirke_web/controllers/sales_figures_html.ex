defmodule BezirkeWeb.SalesFiguresHTML do
  use BezirkeWeb, :html

  embed_templates "sales_figures_html/*"

  @doc """
  Renders a sales_figures form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def sales_figures_form(assigns)
end
