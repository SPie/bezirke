defmodule BezirkeWeb.PlayControllerTest do
  use BezirkeWeb.ConnCase

  import Bezirke.TourFixtures

  @create_attrs %{description: "some description", title: "some title", uuid: "7488a646-e31f-11e4-aace-600308960662"}
  @update_attrs %{description: "some updated description", title: "some updated title", uuid: "7488a646-e31f-11e4-aace-600308960668"}
  @invalid_attrs %{description: nil, title: nil, uuid: nil}

  describe "index" do
    test "lists all plays", %{conn: conn} do
      conn = get(conn, ~p"/plays")
      assert html_response(conn, 200) =~ "Listing Plays"
    end
  end

  describe "new play" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/plays/new")
      assert html_response(conn, 200) =~ "New Play"
    end
  end

  describe "create play" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/plays", play: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/plays/#{id}"

      conn = get(conn, ~p"/plays/#{id}")
      assert html_response(conn, 200) =~ "Play #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/plays", play: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Play"
    end
  end

  describe "edit play" do
    setup [:create_play]

    test "renders form for editing chosen play", %{conn: conn, play: play} do
      conn = get(conn, ~p"/plays/#{play}/edit")
      assert html_response(conn, 200) =~ "Edit Play"
    end
  end

  describe "update play" do
    setup [:create_play]

    test "redirects when data is valid", %{conn: conn, play: play} do
      conn = put(conn, ~p"/plays/#{play}", play: @update_attrs)
      assert redirected_to(conn) == ~p"/plays/#{play}"

      conn = get(conn, ~p"/plays/#{play}")
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, play: play} do
      conn = put(conn, ~p"/plays/#{play}", play: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Play"
    end
  end

  describe "delete play" do
    setup [:create_play]

    test "deletes chosen play", %{conn: conn, play: play} do
      conn = delete(conn, ~p"/plays/#{play}")
      assert redirected_to(conn) == ~p"/plays"

      assert_error_sent 404, fn ->
        get(conn, ~p"/plays/#{play}")
      end
    end
  end

  defp create_play(_) do
    play = play_fixture()
    %{play: play}
  end
end
