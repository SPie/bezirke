defmodule BezirkeWeb.VenueController do
  use BezirkeWeb, :controller

  alias Bezirke.Tour
  alias Bezirke.Venues
  alias Bezirke.Venues.Venue

  def index(conn, _params) do
    venues = Venues.list_venues()
    render(conn, :index, venues: venues)
  end

  def new(conn, _params) do
    changeset = Venues.change_venue(%Venue{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"venue" => venue_params}) do
    Venues.create_venue(venue_params)
    |> handle_create_venue_response(conn)
  end

  defp handle_create_venue_response({:ok, venue}, conn) do
    conn
    |> put_flash(:info, "Venue created successfully.")
    |> redirect(to: ~p"/venues/#{venue}")
  end

  defp handle_create_venue_response({:error, %Ecto.Changeset{} = changeset}, conn) do
    conn
    |> render(:new, changeset: changeset)
  end

  def edit(conn, %{"uuid" => uuid}) do
    venue = Venues.get_venue_by_uuid!(uuid)
    changeset = Venues.change_venue(venue)
    render(conn, :edit, venue: venue, changeset: changeset)
  end

  def update(conn, %{"uuid" => uuid, "venue" => venue_params}) do
    venue = Venues.get_venue_by_uuid!(uuid)

    case Venues.update_venue(venue, venue_params) do
      {:ok, venue} ->
        conn
        |> put_flash(:info, "Venue updated successfully.")
        |> redirect(to: ~p"/venues/#{venue}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, venue: venue, changeset: changeset)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    venue = Venues.get_venue_by_uuid!(uuid)
    {:ok, _venue} = Venues.delete_venue(venue)

    conn
    |> put_flash(:info, "Venue deleted successfully.")
    |> redirect(to: ~p"/venues")
  end
end
