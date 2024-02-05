defmodule BezirkeWeb.SalesFiguresController do
  use BezirkeWeb, :controller

  alias Bezirke.Sales
  alias Bezirke.Sales.SalesFigures
  alias Bezirke.Tour

  def new(conn, %{"performance_uuid" => performance_uuid}) do
    changeset = Sales.change_sales_figures(%SalesFigures{})
    render(conn, :new, changeset: changeset, performance: Tour.get_performance_by_uuid!(performance_uuid))
  end

  def create(conn, %{"performance_uuid" => performance_uuid, "sales_figures" => sales_figures_params}) do
    Sales.create_sales_figures(performance_uuid, sales_figures_params)
    |> handle_create_sales_figures_response(conn)
  end

  defp handle_create_sales_figures_response({:ok, %{new_sales_figures: sales_figures}}, conn) do
    conn
    |> put_flash(:info, "Sales figures created successfully.")
    |> redirect(to: ~p"/sales-figures/#{sales_figures}")
  end

  defp handle_create_sales_figures_response(
    {
      :error,
      :new_sales_figures,
      %Ecto.Changeset{} = changeset,
      _,
    },
    conn
  ) do
    conn
    |> render(:new, changeset: changeset)
  end

  defp handle_create_sales_figures_response({:error, _, _, _}, conn) do
    conn
    # TODO flash message
    |> render(:new)
  end

  def show(conn, %{"uuid" => uuid}) do
    sales_figures = get_sales_figures_with_total_tickets_count(uuid)

    render(conn, :show, sales_figures: sales_figures)
  end

  def edit(conn, %{"uuid" => uuid}) do
    sales_figures = get_sales_figures_with_total_tickets_count(uuid)
    changeset = Sales.change_sales_figures_for_update(sales_figures)

    render(conn, :edit, sales_figures: sales_figures, changeset: changeset)
  end

  defp get_sales_figures_with_total_tickets_count(uuid) do
    sales_figures = Sales.get_sales_figures_by_uuid!(uuid)

    current_tickets_count = Sales.get_current_tickets_count_for_performance(
      sales_figures.performance,
      sales_figures.record_date,
      sales_figures.id
    )

    %SalesFigures{sales_figures | tickets_count: current_tickets_count + sales_figures.tickets_count}
  end

  def update(conn, %{"uuid" => uuid, "sales_figures" => sales_figures_params}) do
    sales_figures = Sales.get_sales_figures_by_uuid!(uuid)

    case Sales.update_sales_figures(sales_figures, sales_figures_params) do
      {:ok, %{updated_sales_figures: sales_figures}} ->
        conn
        |> put_flash(:info, "Sales figures updated successfully.")
        |> redirect(to: ~p"/sales-figures/#{sales_figures}")

      {:error, :updated_sales_figures, %Ecto.Changeset{} = changeset, _} ->
        render(conn, :edit, sales_figures: sales_figures, changeset: changeset)
      {:error, _, _, _} ->
        # TODO flash message
        render(conn, :edit, sales_figures: sales_figures)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    sales_figures = Sales.get_sales_figures_by_uuid!(uuid)
    {:ok, _sales_figures} = Sales.delete_sales_figures(sales_figures)

    conn
    |> put_flash(:info, "Sales figures deleted successfully.")
    |> redirect(to: ~p"/performances/#{sales_figures.performance}")
  end
end
