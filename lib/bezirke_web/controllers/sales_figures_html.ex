defmodule BezirkeWeb.SalesFiguresHTML do
  use BezirkeWeb, :html

  embed_templates "sales_figures_html/*"

  @doc """
  Renders a sales_figures form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def sales_figures_form(assigns)

  def performances_list(_changeset) do
    for performance <- Bezirke.Tour.list_performances() do
      [
        key: performance.production.title <> " - " <> performance.venue.name,
        value: performance.uuid,
      ]
    end
  end
end
