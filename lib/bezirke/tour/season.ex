defmodule Bezirke.Tour.Season do
  use Ecto.Schema
  import Ecto.Changeset

  schema "seasons" do
    field :active, :boolean, default: false
    field :name, :string
    field :uuid, Ecto.UUID

    has_many :productions, Bezirke.Tour.Production
    has_many :subscribers, Bezirke.Tour.Subscriber

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(season, attrs) do
    season
    |> cast(attrs, [:uuid, :name, :active])
    |> validate_required([:uuid, :name, :active])
    |> unique_constraint(:uuid)
  end
end

defimpl Phoenix.Param, for: Bezirke.Tour.Season do
  def to_param(%{uuid: uuid}), do: uuid
end
