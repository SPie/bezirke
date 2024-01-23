defmodule BezirkeWeb.PerformanceController do
  use BezirkeWeb, :controller

  alias Bezirke.Tour
  alias Bezirke.Tour.Performance

  def new(conn, _params) do
    changeset = Tour.change_performance(%Performance{})
    render_new_performance(conn, changeset)
  end

  def create(conn, %{"performance" => performance_params}) do
    Tour.create_performance(performance_params)
    |> handle_create_performance_response(conn)
  end

  defp handle_create_performance_response({:ok, performance}, conn) do
    conn
    |> put_flash(:info, "Performance created successfully.")
    |> redirect(to: ~p"/performances/#{performance}")
  end

  defp handle_create_performance_response({:error, %Ecto.Changeset{} = changeset}, conn) do
    render_new_performance(conn, changeset)
  end

  defp render_new_performance(conn, %Ecto.Changeset{} = changeset), do: render(conn, :new, changeset: changeset)

  def show(conn, %{"uuid" => uuid}) do
    performance = Tour.get_performance_by_uuid!(uuid)
    render(conn, :show, performance: performance)
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
    |> redirect(to: ~p"/performances")
  end
end
