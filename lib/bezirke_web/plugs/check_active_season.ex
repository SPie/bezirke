defmodule BezirkeWeb.Plugs.CheckActiveSeason do
  import Plug.Conn
  import Phoenix.Controller

  use BezirkeWeb, :verified_routes

  def init(_params) do
  end

  def call(%Plug.Conn{assigns: %{active_season: active_season}} = conn, _params)
  when active_season != nil,
    do: conn

  def call(conn, _params) do
    conn
    |> redirect(to: ~p"/seasons/new")
    |> halt()
  end
end
