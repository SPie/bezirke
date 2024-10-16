defmodule Bezirke.Venues.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "venues" do
    field :name, :string
    field :description, :string
    field :capacity, :integer
    field :uuid, Ecto.UUID

    has_many :performances, Bezirke.Tour.Performance
    has_many :subscribers, Bezirke.Tour.Subscriber

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:uuid, :name, :description, :capacity])
    |> validate_required([:uuid, :name, :description, :capacity])
    |> unique_constraint(:uuid)
  end
end

defimpl Phoenix.Param, for: Bezirke.Venues.Venue do
  def to_param(%{uuid: uuid}), do: uuid
end
