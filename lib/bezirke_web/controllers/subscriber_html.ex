defmodule BezirkeWeb.SubscriberHTML do
  use BezirkeWeb, :html

  embed_templates "subscriber_html/*"

  @doc """
  Renders a subscriber form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def subscriber_form(assigns)
end
