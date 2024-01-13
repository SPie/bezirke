defmodule Bezirke.TourFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bezirke.Tour` context.
  """

  @doc """
  Generate a play.
  """
  def play_fixture(attrs \\ %{}) do
    {:ok, play} =
      attrs
      |> Enum.into(%{
        description: "some description",
        title: "some title",
        uuid: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Bezirke.Tour.create_play()

    play
  end

  @doc """
  Generate a unique performance uuid.
  """
  def unique_performance_uuid do
    raise "implement the logic to generate a unique performance uuid"
  end

  @doc """
  Generate a performance.
  """
  def performance_fixture(attrs \\ %{}) do
    {:ok, performance} =
      attrs
      |> Enum.into(%{
        played_at: ~U[2023-12-15 23:46:00Z],
        production_id: 42,
        uuid: unique_performance_uuid(),
        venue_id: 42
      })
      |> Bezirke.Tour.create_performance()

    performance
  end

  @doc """
  Generate a unique season uuid.
  """
  def unique_season_uuid do
    raise "implement the logic to generate a unique season uuid"
  end

  @doc """
  Generate a season.
  """
  def season_fixture(attrs \\ %{}) do
    {:ok, season} =
      attrs
      |> Enum.into(%{
        active: true,
        name: "some name",
        uuid: unique_season_uuid()
      })
      |> Bezirke.Tour.create_season()

    season
  end
end
