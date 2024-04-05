defmodule Bezirke.EventsTest do
  use Bezirke.DataCase

  alias Bezirke.Events

  describe "events" do
    alias Bezirke.Events.Event

    import Bezirke.EventsFixtures

    @invalid_attrs %{label: nil, description: nil, started_at: nil, uuid: nil, ended_at: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{label: "some label", description: "some description", started_at: ~U[2024-04-04 19:52:00Z], uuid: "7488a646-e31f-11e4-aace-600308960662", ended_at: ~U[2024-04-04 19:52:00Z]}

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.label == "some label"
      assert event.description == "some description"
      assert event.started_at == ~U[2024-04-04 19:52:00Z]
      assert event.uuid == "7488a646-e31f-11e4-aace-600308960662"
      assert event.ended_at == ~U[2024-04-04 19:52:00Z]
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{label: "some updated label", description: "some updated description", started_at: ~U[2024-04-05 19:52:00Z], uuid: "7488a646-e31f-11e4-aace-600308960668", ended_at: ~U[2024-04-05 19:52:00Z]}

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.label == "some updated label"
      assert event.description == "some updated description"
      assert event.started_at == ~U[2024-04-05 19:52:00Z]
      assert event.uuid == "7488a646-e31f-11e4-aace-600308960668"
      assert event.ended_at == ~U[2024-04-05 19:52:00Z]
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
