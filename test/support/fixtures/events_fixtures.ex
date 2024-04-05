defmodule Bezirke.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bezirke.Events` context.
  """

  @doc """
  Generate a unique event uuid.
  """
  def unique_event_uuid do
    raise "implement the logic to generate a unique event uuid"
  end

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        description: "some description",
        ended_at: ~U[2024-04-04 19:52:00Z],
        label: "some label",
        started_at: ~U[2024-04-04 19:52:00Z],
        uuid: unique_event_uuid()
      })
      |> Bezirke.Events.create_event()

    event
  end
end
