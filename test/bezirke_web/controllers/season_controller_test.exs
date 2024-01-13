defmodule BezirkeWeb.SeasonControllerTest do
  use BezirkeWeb.ConnCase

  import Bezirke.TourFixtures

  @create_attrs %{active: true, name: "some name", uuid: "7488a646-e31f-11e4-aace-600308960662"}
  @update_attrs %{active: false, name: "some updated name", uuid: "7488a646-e31f-11e4-aace-600308960668"}
  @invalid_attrs %{active: nil, name: nil, uuid: nil}

  describe "index" do
    test "lists all seasons", %{conn: conn} do
      conn = get(conn, ~p"/seasons")
      assert html_response(conn, 200) =~ "Listing Seasons"
    end
  end

  describe "new season" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/seasons/new")
      assert html_response(conn, 200) =~ "New Season"
    end
  end

  describe "create season" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/seasons", season: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/seasons/#{id}"

      conn = get(conn, ~p"/seasons/#{id}")
      assert html_response(conn, 200) =~ "Season #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/seasons", season: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Season"
    end
  end

  describe "edit season" do
    setup [:create_season]

    test "renders form for editing chosen season", %{conn: conn, season: season} do
      conn = get(conn, ~p"/seasons/#{season}/edit")
      assert html_response(conn, 200) =~ "Edit Season"
    end
  end

  describe "update season" do
    setup [:create_season]

    test "redirects when data is valid", %{conn: conn, season: season} do
      conn = put(conn, ~p"/seasons/#{season}", season: @update_attrs)
      assert redirected_to(conn) == ~p"/seasons/#{season}"

      conn = get(conn, ~p"/seasons/#{season}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, season: season} do
      conn = put(conn, ~p"/seasons/#{season}", season: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Season"
    end
  end

  describe "delete season" do
    setup [:create_season]

    test "deletes chosen season", %{conn: conn, season: season} do
      conn = delete(conn, ~p"/seasons/#{season}")
      assert redirected_to(conn) == ~p"/seasons"

      assert_error_sent 404, fn ->
        get(conn, ~p"/seasons/#{season}")
      end
    end
  end

  defp create_season(_) do
    season = season_fixture()
    %{season: season}
  end
end
