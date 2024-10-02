defmodule BezirkeWeb.PerformanceController do
  use BezirkeWeb, :controller

  alias Bezirke.Sales
  alias Bezirke.Tour
  alias Bezirke.Tour.Performance
  alias Bezirke.Venues

  def new(conn, %{"production_uuid" => production_uuid}) do
    changeset = Tour.change_performance(%Performance{})
    render_new_performance(conn, changeset, production_uuid)
  end

  def create(conn, %{"production_uuid" => production_uuid, "performance" => performance_params}) do
    Tour.create_performance({:production, production_uuid}, performance_params)
    |> handle_create_performance_response(conn, production_uuid)
  end

  defp handle_create_performance_response({:ok, performance}, conn, _) do
    conn
    |> put_flash(:info, "Performance created successfully.")
    |> redirect(to: ~p"/performances/#{performance}")
  end

  defp handle_create_performance_response({:error, %Ecto.Changeset{} = changeset}, conn, production_uuid) do
    render_new_performance(conn, changeset, production_uuid)
  end

  defp render_new_performance(conn, %Ecto.Changeset{} = changeset, production_uuid) do
    conn
    |> render(:new_for_production, changeset: changeset, production: Tour.get_production_by_uuid!(production_uuid))
  end

  def show(conn, %{"uuid" => uuid, "origin" => origin}) do
    performance = Tour.get_performance_by_uuid!(uuid)
    sales_figures = Sales.get_sales_figures_with_tickets_count_sum(performance)

    render(conn, :show, performance: performance, sales_figures: sales_figures, origin: origin)
  end

  def show(conn, %{"uuid" => _} = params), do: show(conn, add_origin(params))

  def edit(conn, %{"uuid" => uuid, "origin" => origin}) do
    performance = Tour.get_performance_by_uuid!(uuid)
    changeset = Tour.change_performance(performance)
    render(conn, :edit, performance: performance, changeset: changeset, origin: origin)
  end

  def edit(conn, %{"uuid" => _} = params), do: edit(conn, add_origin(params))

  def update(conn, %{"uuid" => uuid, "performance" => performance_params, "origin" => origin}) do
    performance = Tour.get_performance_by_uuid!(uuid)

    case Tour.update_performance(performance, performance_params) do
      {:ok, performance} ->
        conn
        |> put_flash(:info, "Performance updated successfully.")
        |> redirect(to: ~p"/performances/#{performance}?origin=#{origin}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, performance: performance, changeset: changeset, origin: origin)
    end
  end

  def update(conn, %{"uuid" => _, "performance" => _} = params), do: update(conn, add_origin(params))

  def delete(conn, %{"uuid" => uuid, "origin" => origin}) do
    performance = Tour.get_performance_by_uuid!(uuid)
    {:ok, _performance} = Tour.delete_performance(performance)

    conn = conn
    |> put_flash(:info, "Performance deleted successfully.")

    case origin do
      "venue" -> conn |> redirect(to: ~p"/venues/#{performance.venue}")
      _ -> conn |> redirect(to: ~p"/productions/#{performance.production}")
    end
  end

  def delete(conn, %{"uuid" => _} = params), do: delete(conn, add_origin(params))

  defp add_origin(params), do: Map.put(params, "origin", "production")
end
