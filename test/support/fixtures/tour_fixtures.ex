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
end
