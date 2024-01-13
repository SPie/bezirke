defmodule Bezirke.Tour.Production do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bezirke.Tour

  schema "productions" do
    field :description, :string
    field :title, :string
    field :uuid, Ecto.UUID

    has_many :performances, Bezirke.Tour.Performance
    belongs_to :season, Bezirke.Tour.Season

    timestamps(type: :utc_datetime)

    field :season_uuid, Ecto.UUID, virtual: true
  end

  @doc false
  def changeset(production, attrs) do
    production
    |> cast(attrs, [:uuid, :title, :description, :season_uuid])
    |> cast_season_id()
    |> validate_required([:uuid, :title, :description, :season_id])
    |> unique_constraint(:uuid)
  end

  defp cast_season_id(changeset) do
    case get_change(changeset, :season_uuid) do
      nil -> changeset
      season_uuid ->
        season = Tour.get_season_by_uuid!(season_uuid)
        put_change(changeset, :season_id, season.id)
    end
  end
end

defimpl Phoenix.Param, for: Bezirke.Tour.Production do
  def to_param(%{uuid: uuid}), do: uuid
end
