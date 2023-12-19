defmodule BezirkeWeb.PerformanceControllerTest do
  use BezirkeWeb.ConnCase

  import Bezirke.TourFixtures

  @create_attrs %{uuid: "7488a646-e31f-11e4-aace-600308960662", played_at: ~U[2023-12-15 23:46:00Z], production_id: 42, venue_id: 42}
  @update_attrs %{uuid: "7488a646-e31f-11e4-aace-600308960668", played_at: ~U[2023-12-16 23:46:00Z], production_id: 43, venue_id: 43}
  @invalid_attrs %{uuid: nil, played_at: nil, production_id: nil, venue_id: nil}

  describe "index" do
    test "lists all performances", %{conn: conn} do
      conn = get(conn, ~p"/performances")
      assert html_response(conn, 200) =~ "Listing Performances"
    end
  end

  describe "new performance" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/performances/new")
      assert html_response(conn, 200) =~ "New Performance"
    end
  end

  describe "create performance" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/performances", performance: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/performances/#{id}"

      conn = get(conn, ~p"/performances/#{id}")
      assert html_response(conn, 200) =~ "Performance #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/performances", performance: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Performance"
    end
  end

  describe "edit performance" do
    setup [:create_performance]

    test "renders form for editing chosen performance", %{conn: conn, performance: performance} do
      conn = get(conn, ~p"/performances/#{performance}/edit")
      assert html_response(conn, 200) =~ "Edit Performance"
    end
  end

  describe "update performance" do
    setup [:create_performance]

    test "redirects when data is valid", %{conn: conn, performance: performance} do
      conn = put(conn, ~p"/performances/#{performance}", performance: @update_attrs)
      assert redirected_to(conn) == ~p"/performances/#{performance}"

      conn = get(conn, ~p"/performances/#{performance}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, performance: performance} do
      conn = put(conn, ~p"/performances/#{performance}", performance: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Performance"
    end
  end

  describe "delete performance" do
    setup [:create_performance]

    test "deletes chosen performance", %{conn: conn, performance: performance} do
      conn = delete(conn, ~p"/performances/#{performance}")
      assert redirected_to(conn) == ~p"/performances"

      assert_error_sent 404, fn ->
        get(conn, ~p"/performances/#{performance}")
      end
    end
  end

  defp create_performance(_) do
    performance = performance_fixture()
    %{performance: performance}
  end
end
