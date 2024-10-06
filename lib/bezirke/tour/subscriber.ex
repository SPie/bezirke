defmodule Bezirke.Tour.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bezirke.Tour
  alias Bezirke.Venues

  schema "subscribers" do
    field :quantity, :integer
    field :uuid, Ecto.UUID

    belongs_to :venue, Bezirke.Venues.Venue
    belongs_to :season, Bezirke.Tour.Season

    timestamps(type: :utc_datetime)

    field :venue_uuid, Ecto.UUID, virtual: true
    field :season_uuid, Ecto.UUID, virtual: true
  end

  @doc false
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:uuid, :quantity, :venue_uuid, :season_uuid])
    |> cast_venue()
    |> cast_season()
    |> validate_required([:uuid, :quantity, :venue, :season])
    |> unique_constraint(:uuid)
  end

  defp cast_venue(changeset) do
    case get_change(changeset, :venue_uuid) do
      nil -> changeset
      venue_uuid ->
        venue = Venues.get_venue_by_uuid!(venue_uuid)
        put_change(changeset, :venue, venue)
    end
  end

  defp cast_season(changeset) do
    case get_change(changeset, :season_uuid) do
      nil -> changeset
      season_uuid ->
        season = Tour.get_season_by_uuid!(season_uuid)
        put_change(changeset, :season, season)
    end
  end
end

defimpl Phoenix.Param, for: Bezirke.Tour.Subscriber do
  def to_param(%{uuid: uuid}), do: uuid
end
