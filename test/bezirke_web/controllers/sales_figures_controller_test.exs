defmodule BezirkeWeb.SalesFiguresControllerTest do
  use BezirkeWeb.ConnCase

  import Bezirke.SalesFixtures

  @create_attrs %{uuid: "7488a646-e31f-11e4-aace-600308960662", record_date: ~U[2023-12-26 20:16:00Z], tickets_count: 42, performance_id: 42}
  @update_attrs %{uuid: "7488a646-e31f-11e4-aace-600308960668", record_date: ~U[2023-12-27 20:16:00Z], tickets_count: 43, performance_id: 43}
  @invalid_attrs %{uuid: nil, record_date: nil, tickets_count: nil, performance_id: nil}

  describe "index" do
    test "lists all sales_figures", %{conn: conn} do
      conn = get(conn, ~p"/sales_figures")
      assert html_response(conn, 200) =~ "Listing Sales figures"
    end
  end

  describe "new sales_figures" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/sales_figures/new")
      assert html_response(conn, 200) =~ "New Sales figures"
    end
  end

  describe "create sales_figures" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/sales_figures", sales_figures: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/sales_figures/#{id}"

      conn = get(conn, ~p"/sales_figures/#{id}")
      assert html_response(conn, 200) =~ "Sales figures #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/sales_figures", sales_figures: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Sales figures"
    end
  end

  describe "edit sales_figures" do
    setup [:create_sales_figures]

    test "renders form for editing chosen sales_figures", %{conn: conn, sales_figures: sales_figures} do
      conn = get(conn, ~p"/sales_figures/#{sales_figures}/edit")
      assert html_response(conn, 200) =~ "Edit Sales figures"
    end
  end

  describe "update sales_figures" do
    setup [:create_sales_figures]

    test "redirects when data is valid", %{conn: conn, sales_figures: sales_figures} do
      conn = put(conn, ~p"/sales_figures/#{sales_figures}", sales_figures: @update_attrs)
      assert redirected_to(conn) == ~p"/sales_figures/#{sales_figures}"

      conn = get(conn, ~p"/sales_figures/#{sales_figures}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, sales_figures: sales_figures} do
      conn = put(conn, ~p"/sales_figures/#{sales_figures}", sales_figures: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Sales figures"
    end
  end

  describe "delete sales_figures" do
    setup [:create_sales_figures]

    test "deletes chosen sales_figures", %{conn: conn, sales_figures: sales_figures} do
      conn = delete(conn, ~p"/sales_figures/#{sales_figures}")
      assert redirected_to(conn) == ~p"/sales_figures"

      assert_error_sent 404, fn ->
        get(conn, ~p"/sales_figures/#{sales_figures}")
      end
    end
  end

  defp create_sales_figures(_) do
    sales_figures = sales_figures_fixture()
    %{sales_figures: sales_figures}
  end
end
