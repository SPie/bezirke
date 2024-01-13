defmodule BezirkeWeb.SeasonController do
  use BezirkeWeb, :controller

  alias Bezirke.Tour
  alias Bezirke.Tour.Season

  def index(conn, _params) do
    seasons = Tour.list_seasons()
    render(conn, :index, seasons: seasons)
  end

  def new(conn, _params) do
    changeset = Tour.change_season(%Season{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"season" => season_params}) do
    Tour.create_season(season_params)
    |> handle_create_season_response(conn)
  end

  defp handle_create_season_response({:ok, season}, conn) do
    conn
    |> put_flash(:info, "Season created successfully.")
    |> redirect(to: ~p"/seasons/#{season}")
  end

  defp handle_create_season_response({:error, %Ecto.Changeset{} = changeset}, conn) do
    conn
    |> render(conn, :new, changeset: changeset)
  end

  def show(conn, %{"uuid" => uuid}) do
    season = Tour.get_season_by_uuid!(uuid)
    render(conn, :show, season: season)
  end

  def edit(conn, %{"uuid" => uuid}) do
    season = Tour.get_season_by_uuid!(uuid)
    changeset = Tour.change_season(season)
    render(conn, :edit, season: season, changeset: changeset)
  end

  def update(conn, %{"uuid" => uuid, "season" => season_params}) do
    season = Tour.get_season_by_uuid!(uuid)

    case Tour.update_season(season, season_params) do
      {:ok, season} ->
        conn
        |> put_flash(:info, "Season updated successfully.")
        |> redirect(to: ~p"/seasons/#{season}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, season: season, changeset: changeset)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    season = Tour.get_season_by_uuid!(uuid)
    {:ok, _season} = Tour.delete_season(season)

    conn
    |> put_flash(:info, "Season deleted successfully.")
    |> redirect(to: ~p"/seasons")
  end
end
