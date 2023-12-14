defmodule BezirkeWeb.PlayController do
  use BezirkeWeb, :controller

  alias Bezirke.Tour
  alias Bezirke.Tour.Play

  def index(conn, _params) do
    plays = Tour.list_plays()
    render(conn, :index, plays: plays)
  end

  def new(conn, _params) do
    changeset = Tour.change_play(%Play{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"play" => play_params}) do
    Tour.create_play(play_params)
    |> handle_create_play_response(conn)
  end

  defp handle_create_play_response({:ok, play}, conn) do
    conn
    |> put_flash(:info, "Play created successfully.")
    |> redirect(to: ~p"/plays/#{play.uuid}")
  end

  defp handle_create_play_response({:error, %Ecto.Changeset{} = changeset}, conn) do
    conn
    |> render(:new, changeset: changeset)
  end

  def show(conn, %{"uuid" => uuid}) do
    play = Tour.get_play_by_uuid!(uuid)
    render(conn, :show, play: play)
  end

  def edit(conn, %{"uuid" => uuid}) do
    play = Tour.get_play_by_uuid!(uuid)
    changeset = Tour.change_play(play)
    render(conn, :edit, play: play, changeset: changeset)
  end

  def update(conn, %{"uuid" => uuid, "play" => play_params}) do
    play = Tour.get_play_by_uuid!(uuid)

    case Tour.update_play(play, play_params) do
      {:ok, play} ->
        conn
        |> put_flash(:info, "Play updated successfully.")
        |> redirect(to: ~p"/plays/#{play.uuid}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, play: play, changeset: changeset)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    play = Tour.get_play_by_uuid!(uuid)
    {:ok, _play} = Tour.delete_play(play)

    conn
    |> put_flash(:info, "Play deleted successfully.")
    |> redirect(to: ~p"/plays")
  end
end
