defmodule BezirkeWeb.ProductionController do
  use BezirkeWeb, :controller

  alias Bezirke.Tour
  alias Bezirke.Tour.Production

  def index(conn, _params) do
    productions = Tour.list_productions()
    render(conn, :index, productions: productions)
  end

  def new(conn, _params) do
    changeset = Tour.change_production(%Production{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"production" => production_params}) do
    Tour.create_production(production_params)
    |> handle_create_production_response(conn)
  end

  defp handle_create_production_response({:ok, production}, conn) do
    conn
    |> put_flash(:info, "Production created successfully.")
    |> redirect(to: ~p"/productions/#{production.uuid}")
  end

  defp handle_create_production_response({:error, %Ecto.Changeset{} = changeset}, conn) do
    conn
    |> render(:new, changeset: changeset)
  end

  def show(conn, %{"uuid" => uuid}) do
    production = Tour.get_production_by_uuid!(uuid)

    performances =
      production
      |> Tour.get_performances_for_production()
      |> Enum.sort_by(&(&1.played_at), DateTime)

    render(conn, :show, production: production, performances: performances)
  end

  def edit(conn, %{"uuid" => uuid}) do
    production = Tour.get_production_by_uuid!(uuid)
    changeset = Tour.change_production(production)
    render(conn, :edit, production: production, changeset: changeset)
  end

  def update(conn, %{"uuid" => uuid, "production" => production_params}) do
    production = Tour.get_production_by_uuid!(uuid)

    case Tour.update_production(production, production_params) do
      {:ok, production} ->
        conn
        |> put_flash(:info, "Production updated successfully.")
        |> redirect(to: ~p"/productions/#{production.uuid}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, production: production, changeset: changeset)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    production = Tour.get_production_by_uuid!(uuid)
    {:ok, _production} = Tour.delete_production(production)

    conn
    |> put_flash(:info, "Production deleted successfully.")
    |> redirect(to: ~p"/productions")
  end
end
