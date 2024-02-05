defmodule Bezirke.Tour.Performance do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bezirke.Venues

  schema "performances" do
    field :uuid, Ecto.UUID
    field :played_at, :utc_datetime
    field :capacity, :integer

    belongs_to :production, Bezirke.Tour.Production
    belongs_to :venue, Bezirke.Venues.Venue

    has_many :sales_figures, Bezirke.Sales.SalesFigures

    timestamps(type: :utc_datetime)

    field :venue_uuid, Ecto.UUID, virtual: true
  end

  @doc false
  def changeset(performance, attrs) do
    performance
    |> cast(attrs, [:uuid, :played_at, :capacity, :venue_uuid])
    |> cast_venue_id()
    |> validate_required([:uuid, :played_at, :capacity, :production, :venue_id])
    |> unique_constraint(:uuid)
  end

  defp cast_venue_id(changeset) do
    case get_change(changeset, :venue_uuid) do
      nil -> changeset
      venue_uuid ->
        venue = Venues.get_venue_by_uuid!(venue_uuid)
        put_change(changeset, :venue_id, venue.id)
    end
  end
end

defimpl Phoenix.Param, for: Bezirke.Tour.Performance do
  def to_param(%{uuid: uuid}), do: uuid
end
