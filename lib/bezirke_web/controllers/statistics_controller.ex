defmodule BezirkeWeb.StatisticsController do
  use BezirkeWeb, :controller

  def production_sales(conn, _param) do
    render(conn, :production_sales)
  end
end
