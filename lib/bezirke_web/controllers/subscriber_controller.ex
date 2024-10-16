defmodule BezirkeWeb.SubscriberController do
  use BezirkeWeb, :controller

  alias Bezirke.Tour
  alias Bezirke.Tour.Subscriber
  alias Bezirke.Venues

  def new(conn, %{"venue_uuid" => venue_uuid, "season_uuid" => season_uuid}) do
    venue = Venues.get_venue_by_uuid!(venue_uuid)
    season = Tour.get_season_by_uuid!(season_uuid)

    changeset = Tour.change_subscriber(%Subscriber{})

    render(conn, :new, changeset: changeset, venue: venue, season: season)
  end

  def create(
    conn,
    %{
      "venue_uuid" => venue_uuid,
      "season_uuid" => season_uuid,
      "subscriber" => subscriber_params
    }
  ) do
    venue = Venues.get_venue_by_uuid!(venue_uuid)
    season = Tour.get_season_by_uuid!(season_uuid)

    case Tour.create_subscriber(venue, season, subscriber_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Subscribers created successfully.")
        |> redirect(to: ~p"/venues/#{venue}/performances?season=#{season}")
      {:error, changeset} ->
        render(conn, :new, changeset: changeset, venue: venue, season: season)
    end
  end

  def edit(conn, %{"uuid" => subscriber_uuid}) do
    subscriber = Tour.get_subscriber_by_uuid!(subscriber_uuid)
    changeset = Tour.change_subscriber(subscriber)

    render(conn, :edit, changeset: changeset, subscriber: subscriber)
  end

  def update(conn, %{"uuid" => subscriber_uuid, "subscriber" => subscriber_params}) do
    subscriber = Tour.get_subscriber_by_uuid!(subscriber_uuid)

    case Tour.update_subscriber(subscriber, subscriber_params) do
      {:ok, subscriber} ->
        conn
        |> put_flash(:info, "Subscribers updated successfully.")
        |> redirect(to: ~p"/venues/#{subscriber.venue}?season=#{subscriber.season}")
      {:error, changeset} ->
        render(conn, :edit, changeset: changeset, subscriber: subscriber)
    end
  end
end
