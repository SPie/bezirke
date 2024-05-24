defmodule Bezirke.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:uuid, :label, :description, :started_at, :ended_at]}

  schema "events" do
    field :label, :string
    field :description, :string
    field :started_at, :date
    field :ended_at, :date
    field :uuid, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:uuid, :label, :description, :started_at, :ended_at])
    |> validate_required([:uuid, :label, :started_at])
    |> validate_ended_at()
    |> unique_constraint(:uuid)
  end

  defp validate_ended_at(changeset) do
    started_at = get_field(changeset, :started_at)
    ended_at = get_field(changeset, :ended_at)

    changeset
    |> validate_ended_at(started_at, ended_at)
  end

  defp validate_ended_at(changeset, started_at, ended_at)
  when started_at == nil or ended_at == nil,
    do: changeset

  defp validate_ended_at(changeset, started_at, ended_at) do
    case Date.compare(started_at, ended_at) do
      :gt -> add_error(changeset, :ended_at, "can't be before start", validation: :ended_at)
      _ -> changeset
    end
  end
end

defimpl Phoenix.Param, for: Bezirke.Events.Event do
  def to_param(%{uuid: uuid}), do: uuid
end
