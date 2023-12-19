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

  describe "performances" do
    alias Bezirke.Tour.Performance

    import Bezirke.TourFixtures

    @invalid_attrs %{uuid: nil, played_at: nil, production_id: nil, venue_id: nil}

    test "list_performances/0 returns all performances" do
      performance = performance_fixture()
      assert Tour.list_performances() == [performance]
    end

    test "get_performance!/1 returns the performance with given id" do
      performance = performance_fixture()
      assert Tour.get_performance!(performance.id) == performance
    end

    test "create_performance/1 with valid data creates a performance" do
      valid_attrs = %{uuid: "7488a646-e31f-11e4-aace-600308960662", played_at: ~U[2023-12-15 23:46:00Z], production_id: 42, venue_id: 42}

      assert {:ok, %Performance{} = performance} = Tour.create_performance(valid_attrs)
      assert performance.uuid == "7488a646-e31f-11e4-aace-600308960662"
      assert performance.played_at == ~U[2023-12-15 23:46:00Z]
      assert performance.production_id == 42
      assert performance.venue_id == 42
    end

    test "create_performance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tour.create_performance(@invalid_attrs)
    end

    test "update_performance/2 with valid data updates the performance" do
      performance = performance_fixture()
      update_attrs = %{uuid: "7488a646-e31f-11e4-aace-600308960668", played_at: ~U[2023-12-16 23:46:00Z], production_id: 43, venue_id: 43}

      assert {:ok, %Performance{} = performance} = Tour.update_performance(performance, update_attrs)
      assert performance.uuid == "7488a646-e31f-11e4-aace-600308960668"
      assert performance.played_at == ~U[2023-12-16 23:46:00Z]
      assert performance.production_id == 43
      assert performance.venue_id == 43
    end

    test "update_performance/2 with invalid data returns error changeset" do
      performance = performance_fixture()
      assert {:error, %Ecto.Changeset{}} = Tour.update_performance(performance, @invalid_attrs)
      assert performance == Tour.get_performance!(performance.id)
    end

    test "delete_performance/1 deletes the performance" do
      performance = performance_fixture()
      assert {:ok, %Performance{}} = Tour.delete_performance(performance)
      assert_raise Ecto.NoResultsError, fn -> Tour.get_performance!(performance.id) end
    end

    test "change_performance/1 returns a performance changeset" do
      performance = performance_fixture()
      assert %Ecto.Changeset{} = Tour.change_performance(performance)
    end
  end
end
