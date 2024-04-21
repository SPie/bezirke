defmodule BezirkeWeb.SalesFiguresController do
  use BezirkeWeb, :controller

  alias Phoenix.HTML.Safe.DateTime
  alias Bezirke.Sales
  alias Bezirke.Sales.MultiSalesFigures
  alias Bezirke.Sales.SalesFigures
  alias Bezirke.Tour

  def new(conn, %{"production_uuid" => production_uuid}) do
    production = Tour.get_production_by_uuid!(production_uuid)
    performances = Tour.get_performances_for_production(production)

    changeset = Sales.change_multi_sales_figures(%MultiSalesFigures{}, performances)

    render_new(conn, :new, changeset, production, performances)
  end

  def create(conn, %{"production_uuid" => production_uuid, "multi_sales_figures" => multi_sales_figures}) do
    multi_sales_figures
    |> Sales.create_multi_sales_figures()
    |> handle_create_sales_figures_response(conn, Tour.get_production_by_uuid!(production_uuid), :new)
  end

  defp render_new(conn, template, changeset, production, performances) do
    conn
    |> render(template,
      changeset: changeset,
      production: production,
      performance_labels: get_performance_labels(performances)
    )
  end

  def new_final(conn, %{"production_uuid" => production_uuid}) do
    production = Tour.get_production_by_uuid!(production_uuid)
    performances = Tour.get_performances_for_production(production)

    changeset = Sales.change_final_sales_figures(%MultiSalesFigures{}, performances)

    render_new(conn, :new_final, changeset, production, performances)
  end

  def create_final(conn, %{"production_uuid" => production_uuid, "multi_sales_figures" => multi_sales_figures}) do
    multi_sales_figures
    |> Sales.create_final_sales_figures()
    |> handle_create_sales_figures_response(conn, Tour.get_production_by_uuid!(production_uuid), :new_final)
  end

  defp handle_create_sales_figures_response({:ok, _}, conn, production, _) do
    conn
    |> put_flash(:info, "Sales figures created successfully.")
    |> redirect(to: ~p"/productions/#{production}")
  end

  defp handle_create_sales_figures_response({:error, %Ecto.Changeset{} = changeset}, conn, production, template) do
    render_new(conn, template, changeset, production, Tour.get_performances_for_production(production))
  end

  defp get_performance_labels(performances) do
    performances
    |> Enum.map(fn performance ->
      played_at =
        performance.played_at
        |> Calendar.strftime("%d.%m.%Y %H:%M")

      {performance.uuid, performance.venue.name <> " " <> played_at}
    end)
    |> Enum.into(%{})
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
