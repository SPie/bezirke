defmodule Bezirke.Venues.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "venues" do
    field :name, :string
    field :description, :string
    field :uuid, Ecto.UUID
    field :capacity, :integer

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
