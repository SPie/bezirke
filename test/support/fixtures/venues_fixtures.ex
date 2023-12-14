defmodule Bezirke.VenuesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bezirke.Venues` context.
  """

  @doc """
  Generate a unique venue uuid.
  """
  def unique_venue_uuid do
    raise "implement the logic to generate a unique venue uuid"
  end

  @doc """
  Generate a venue.
  """
  def venue_fixture(attrs \\ %{}) do
    {:ok, venue} =
      attrs
      |> Enum.into(%{
        capacity: 42,
        description: "some description",
        name: "some name",
        uuid: unique_venue_uuid()
      })
      |> Bezirke.Venues.create_venue()

    venue
  end
end
