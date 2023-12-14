defmodule Bezirke.TourTest do
  use Bezirke.DataCase

  alias Bezirke.Tour

  describe "plays" do
    alias Bezirke.Tour.Play

    import Bezirke.TourFixtures

    @invalid_attrs %{description: nil, title: nil, uuid: nil}

    test "list_plays/0 returns all plays" do
      play = play_fixture()
      assert Tour.list_plays() == [play]
    end

    test "get_play!/1 returns the play with given id" do
      play = play_fixture()
      assert Tour.get_play!(play.id) == play
    end

    test "create_play/1 with valid data creates a play" do
      valid_attrs = %{description: "some description", title: "some title", uuid: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %Play{} = play} = Tour.create_play(valid_attrs)
      assert play.description == "some description"
      assert play.title == "some title"
      assert play.uuid == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_play/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tour.create_play(@invalid_attrs)
    end

    test "update_play/2 with valid data updates the play" do
      play = play_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", uuid: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %Play{} = play} = Tour.update_play(play, update_attrs)
      assert play.description == "some updated description"
      assert play.title == "some updated title"
      assert play.uuid == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_play/2 with invalid data returns error changeset" do
      play = play_fixture()
      assert {:error, %Ecto.Changeset{}} = Tour.update_play(play, @invalid_attrs)
      assert play == Tour.get_play!(play.id)
    end

    test "delete_play/1 deletes the play" do
      play = play_fixture()
      assert {:ok, %Play{}} = Tour.delete_play(play)
      assert_raise Ecto.NoResultsError, fn -> Tour.get_play!(play.id) end
    end

    test "change_play/1 returns a play changeset" do
      play = play_fixture()
      assert %Ecto.Changeset{} = Tour.change_play(play)
    end
  end
end
