defmodule Bezirke.Tour.Play do
  use Ecto.Schema
  import Ecto.Changeset

  schema "plays" do
    field :description, :string
    field :title, :string
    field :uuid, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(play, attrs) do
    play
    |> cast(attrs, [:uuid, :title, :description])
    |> validate_required([:uuid, :title, :description])
    |> unique_constraint(:uuid)
  end
end

defimpl Phoenix.Param, for: Bezirke.Tour.Play do
  def to_param(%{uuid: uuid}), do: uuid
end
