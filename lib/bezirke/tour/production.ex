defmodule Bezirke.Tour.Production do
  use Ecto.Schema
  import Ecto.Changeset

  schema "productions" do
    field :description, :string
    field :title, :string
    field :uuid, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(production, attrs) do
    production
    |> cast(attrs, [:uuid, :title, :description])
    |> validate_required([:uuid, :title, :description])
    |> unique_constraint(:uuid)
  end
end

defimpl Phoenix.Param, for: Bezirke.Tour.Production do
  def to_param(%{uuid: uuid}), do: uuid
end
