defmodule BezirkeWeb.EventController do
  use BezirkeWeb, :controller

  alias Bezirke.Events
  alias Bezirke.Events.Event

  def index(conn, _params) do
    events = Events.list_events()
    render(conn, :index, events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render_new_performance(conn, changeset)
  end

  def create(conn, %{"event" => event_params}) do
    event_params
    |> Events.create_event()
    |> handle_create_event_response(conn)
  end

  defp handle_create_event_response({:ok, event}, conn) do
    conn
    |> put_flash(:info, "Event created successfully.")
    |> redirect(to: ~p"/events/#{event}")
  end

  defp handle_create_event_response({:error, %Ecto.Changeset{} = changeset}, conn) do
    render_new_performance(conn, changeset)
  end

  defp render_new_performance(conn, %Ecto.Changeset{} = changeset) do
    render(conn, :new, changeset: changeset)
  end

  def show(conn, %{"uuid" => uuid}) do
    event = Events.get_event_by_uuid!(uuid)
    render(conn, :show, event: event)
  end

  def edit(conn, %{"uuid" => uuid}) do
    event = Events.get_event_by_uuid!(uuid)
    changeset = Events.change_event(event)
    render(conn, :edit, event: event, changeset: changeset)
  end

  def update(conn, %{"uuid" => uuid, "event" => event_params}) do
    event = Events.get_event_by_uuid!(uuid)

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: ~p"/events/#{event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    event = Events.get_event_by_uuid!(uuid)
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: ~p"/events")
  end
end
