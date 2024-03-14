defmodule Bezirke.SalesTest do
  use Bezirke.DataCase

  alias Bezirke.Sales

  describe "sales_figures" do
    alias Bezirke.Sales.SalesFigures

    import Bezirke.SalesFixtures

    @invalid_attrs %{uuid: nil, record_date: nil, tickets_count: nil, performance_id: nil}

  end
end
