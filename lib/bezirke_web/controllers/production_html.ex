defmodule BezirkeWeb.ProductionHTML do
  use BezirkeWeb, :html

  embed_templates "production_html/*"

  @doc """
  Renders a production form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def production_form(assigns)

  def seasons_list(changeset) do
    season_uuid = Ecto.Changeset.get_change(changeset, :season_uuid)

    Bezirke.Tour.list_seasons()
    |> Enum.map(fn season ->
      [
        key: season.name,
        value: season.uuid,
        selected: season.uuid == season_uuid,
      ]
    end)
  end
end
