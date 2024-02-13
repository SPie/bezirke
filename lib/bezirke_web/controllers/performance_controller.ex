defmodule BezirkeWeb.PerformanceController do
  use BezirkeWeb, :controller

  alias Bezirke.Tour
  alias Bezirke.Tour.Performance
  alias Bezirke.Venues

  def new(conn, %{"production_uuid" => production_uuid}) do
    changeset = Tour.change_performance(%Performance{})
    render_new_performance(conn, changeset, {:production, production_uuid})
  end

  def new(conn, %{"venue_uuid" => venue_uuid}) do
    changeset = Tour.change_performance(%Performance{})
    render_new_performance(conn, changeset, {:venue, venue_uuid})
  end

  def create(conn, %{"production_uuid" => production_uuid, "performance" => performance_params}) do
    Tour.create_performance({:production, production_uuid}, performance_params)
    |> handle_create_performance_response(conn, {:production, production_uuid})
  end

  def create(conn, %{"venue_uuid" => venue_uuid, "performance" => performance_params}) do
    Tour.create_performance({:venue, venue_uuid}, performance_params)
    |> handle_create_performance_response(conn, {:venue, venue_uuid})
  end

  defp handle_create_performance_response({:ok, performance}, conn, _) do
    conn
    |> put_flash(:info, "Performance created successfully.")
    |> redirect(to: ~p"/performances/#{performance}")
  end

  defp handle_create_performance_response({:error, %Ecto.Changeset{} = changeset}, conn, production_or_venue) do
    render_new_performance(conn, changeset, production_or_venue)
  end

  defp render_new_performance(conn, %Ecto.Changeset{} = changeset, {:production, production_uuid}) do
    conn
    |> render(:new_for_production, changeset: changeset, production: Tour.get_production_by_uuid!(production_uuid))
  end

  defp render_new_performance(conn, %Ecto.Changeset{} = changeset, {:venue, venue_uuid}) do
    conn
    |> render(:new_for_venue, changeset: changeset, venue: Venues.get_venue_by_uuid!(venue_uuid))
  end

  def show(conn, %{"uuid" => uuid}) do
    {performance, sales_figures} = Tour.get_performance_with_sales_figures!(uuid)

    render(conn, :show, performance: performance, sales_figures: sales_figures)
  end

  def edit(conn, %{"uuid" => uuid}) do
    performance = Tour.get_performance_by_uuid!(uuid)
    changeset = Tour.change_performance(performance)
    render(conn, :edit, performance: performance, changeset: changeset)
  end

  def update(conn, %{"uuid" => uuid, "performance" => performance_params}) do
    performance = Tour.get_performance_by_uuid!(uuid)

    case Tour.update_performance(performance, performance_params) do
      {:ok, performance} ->
        conn
        |> put_flash(:info, "Performance updated successfully.")
        |> redirect(to: ~p"/performances/#{performance}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, performance: performance, changeset: changeset)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    performance = Tour.get_performance_by_uuid!(uuid)
    {:ok, _performance} = Tour.delete_performance(performance)

    conn
    |> put_flash(:info, "Performance deleted successfully.")
    |> redirect(to: ~p"/productions/#{performance.production}")
  end
end
