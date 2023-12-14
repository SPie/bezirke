defmodule Bezirke.VenuesTest do
  use Bezirke.DataCase

  alias Bezirke.Venues

  describe "venues" do
    alias Bezirke.Venues.Venue

    import Bezirke.VenuesFixtures

    @invalid_attrs %{name: nil, description: nil, uuid: nil, capacity: nil}

    test "list_venues/0 returns all venues" do
      venue = venue_fixture()
      assert Venues.list_venues() == [venue]
    end

    test "get_venue!/1 returns the venue with given id" do
      venue = venue_fixture()
      assert Venues.get_venue!(venue.id) == venue
    end

    test "create_venue/1 with valid data creates a venue" do
      valid_attrs = %{name: "some name", description: "some description", uuid: "7488a646-e31f-11e4-aace-600308960662", capacity: 42}

      assert {:ok, %Venue{} = venue} = Venues.create_venue(valid_attrs)
      assert venue.name == "some name"
      assert venue.description == "some description"
      assert venue.uuid == "7488a646-e31f-11e4-aace-600308960662"
      assert venue.capacity == 42
    end

    test "create_venue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Venues.create_venue(@invalid_attrs)
    end

    test "update_venue/2 with valid data updates the venue" do
      venue = venue_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", uuid: "7488a646-e31f-11e4-aace-600308960668", capacity: 43}

      assert {:ok, %Venue{} = venue} = Venues.update_venue(venue, update_attrs)
      assert venue.name == "some updated name"
      assert venue.description == "some updated description"
      assert venue.uuid == "7488a646-e31f-11e4-aace-600308960668"
      assert venue.capacity == 43
    end

    test "update_venue/2 with invalid data returns error changeset" do
      venue = venue_fixture()
      assert {:error, %Ecto.Changeset{}} = Venues.update_venue(venue, @invalid_attrs)
      assert venue == Venues.get_venue!(venue.id)
    end

    test "delete_venue/1 deletes the venue" do
      venue = venue_fixture()
      assert {:ok, %Venue{}} = Venues.delete_venue(venue)
      assert_raise Ecto.NoResultsError, fn -> Venues.get_venue!(venue.id) end
    end

    test "change_venue/1 returns a venue changeset" do
      venue = venue_fixture()
      assert %Ecto.Changeset{} = Venues.change_venue(venue)
    end
  end
end
