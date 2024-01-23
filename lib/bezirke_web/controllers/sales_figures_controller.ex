defmodule BezirkeWeb.SalesFiguresController do
  use BezirkeWeb, :controller

  alias Bezirke.Sales
  alias Bezirke.Sales.SalesFigures

  def new(conn, _params) do
    changeset = Sales.change_sales_figures(%SalesFigures{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"sales_figures" => sales_figures_params}) do
    case Sales.create_sales_figures(sales_figures_params) do
      {:ok, sales_figures} ->
        conn
        |> put_flash(:info, "Sales figures created successfully.")
        |> redirect(to: ~p"/sales-figures/#{sales_figures}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"uuid" => uuid}) do
    sales_figures = Sales.get_sales_figures_by_uuid!(uuid)
    render(conn, :show, sales_figures: sales_figures)
  end

  def edit(conn, %{"uuid" => uuid}) do
    sales_figures = Sales.get_sales_figures_by_uuid!(uuid)
    changeset = Sales.change_sales_figures(sales_figures)
    render(conn, :edit, sales_figures: sales_figures, changeset: changeset)
  end

  def update(conn, %{"uuid" => uuid, "sales_figures" => sales_figures_params}) do
    sales_figures = Sales.get_sales_figures_by_uuid!(uuid)

    case Sales.update_sales_figures(sales_figures, sales_figures_params) do
      {:ok, sales_figures} ->
        conn
        |> put_flash(:info, "Sales figures updated successfully.")
        |> redirect(to: ~p"/sales-figures/#{sales_figures}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, sales_figures: sales_figures, changeset: changeset)
    end
  end

  def delete(conn, %{"uuid" => uuid}) do
    sales_figures = Sales.get_sales_figures_by_uuid!(uuid)
    {:ok, _sales_figures} = Sales.delete_sales_figures(sales_figures)

    conn
    |> put_flash(:info, "Sales figures deleted successfully.")
    |> redirect(to: ~p"/sales-figures")
  end
end
