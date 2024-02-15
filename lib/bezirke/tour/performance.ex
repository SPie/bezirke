defmodule Bezirke.Tour.Performance do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bezirke.Tour
  alias Bezirke.Venues

  schema "performances" do
    field :uuid, Ecto.UUID
    field :played_at, :utc_datetime
    field :capacity, :integer

    belongs_to :production, Bezirke.Tour.Production
    belongs_to :venue, Bezirke.Venues.Venue

    has_many :sales_figures, Bezirke.Sales.SalesFigures

    timestamps(type: :utc_datetime)

    field :production_uuid, Ecto.UUID, virtual: true
    field :venue_uuid, Ecto.UUID, virtual: true
  end

  @doc false
  def changeset(performance, attrs) do
    performance
    |> cast(attrs, [:uuid, :played_at, :capacity, :production_uuid, :venue_uuid])
    |> cast_production()
    |> cast_venue()
    |> validate_required([:uuid, :played_at, :capacity, :production, :venue])
    |> unique_constraint(:uuid)
  end

  defp cast_production(changeset) do
    case get_change(changeset, :production_uuid) do
      nil -> changeset
      production_uuid -> put_change(changeset, :production, Tour.get_production_by_uuid!(production_uuid))
    end
  end

  defp cast_venue(changeset) do
    case get_change(changeset, :venue_uuid) do
      nil -> changeset
      venue_uuid -> put_change(changeset, :venue, Venues.get_venue_by_uuid!(venue_uuid))
    end
  end
end

defimpl Phoenix.Param, for: Bezirke.Tour.Performance do
  def to_param(%{uuid: uuid}), do: uuid
end
