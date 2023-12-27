defmodule Bezirke.SalesTest do
  use Bezirke.DataCase

  alias Bezirke.Sales

  describe "sales_figures" do
    alias Bezirke.Sales.SalesFigures

    import Bezirke.SalesFixtures

    @invalid_attrs %{uuid: nil, record_date: nil, tickets_count: nil, performance_id: nil}

    test "list_sales_figures/0 returns all sales_figures" do
      sales_figures = sales_figures_fixture()
      assert Sales.list_sales_figures() == [sales_figures]
    end

    test "get_sales_figures!/1 returns the sales_figures with given id" do
      sales_figures = sales_figures_fixture()
      assert Sales.get_sales_figures!(sales_figures.id) == sales_figures
    end

    test "create_sales_figures/1 with valid data creates a sales_figures" do
      valid_attrs = %{uuid: "7488a646-e31f-11e4-aace-600308960662", record_date: ~U[2023-12-26 20:16:00Z], tickets_count: 42, performance_id: 42}

      assert {:ok, %SalesFigures{} = sales_figures} = Sales.create_sales_figures(valid_attrs)
      assert sales_figures.uuid == "7488a646-e31f-11e4-aace-600308960662"
      assert sales_figures.record_date == ~U[2023-12-26 20:16:00Z]
      assert sales_figures.tickets_count == 42
      assert sales_figures.performance_id == 42
    end

    test "create_sales_figures/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sales.create_sales_figures(@invalid_attrs)
    end

    test "update_sales_figures/2 with valid data updates the sales_figures" do
      sales_figures = sales_figures_fixture()
      update_attrs = %{uuid: "7488a646-e31f-11e4-aace-600308960668", record_date: ~U[2023-12-27 20:16:00Z], tickets_count: 43, performance_id: 43}

      assert {:ok, %SalesFigures{} = sales_figures} = Sales.update_sales_figures(sales_figures, update_attrs)
      assert sales_figures.uuid == "7488a646-e31f-11e4-aace-600308960668"
      assert sales_figures.record_date == ~U[2023-12-27 20:16:00Z]
      assert sales_figures.tickets_count == 43
      assert sales_figures.performance_id == 43
    end

    test "update_sales_figures/2 with invalid data returns error changeset" do
      sales_figures = sales_figures_fixture()
      assert {:error, %Ecto.Changeset{}} = Sales.update_sales_figures(sales_figures, @invalid_attrs)
      assert sales_figures == Sales.get_sales_figures!(sales_figures.id)
    end

    test "delete_sales_figures/1 deletes the sales_figures" do
      sales_figures = sales_figures_fixture()
      assert {:ok, %SalesFigures{}} = Sales.delete_sales_figures(sales_figures)
      assert_raise Ecto.NoResultsError, fn -> Sales.get_sales_figures!(sales_figures.id) end
    end

    test "change_sales_figures/1 returns a sales_figures changeset" do
      sales_figures = sales_figures_fixture()
      assert %Ecto.Changeset{} = Sales.change_sales_figures(sales_figures)
    end
  end
end
