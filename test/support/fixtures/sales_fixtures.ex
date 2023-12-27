defmodule Bezirke.SalesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bezirke.Sales` context.
  """

  @doc """
  Generate a unique sales_figures uuid.
  """
  def unique_sales_figures_uuid do
    raise "implement the logic to generate a unique sales_figures uuid"
  end

  @doc """
  Generate a sales_figures.
  """
  def sales_figures_fixture(attrs \\ %{}) do
    {:ok, sales_figures} =
      attrs
      |> Enum.into(%{
        performance_id: 42,
        record_date: ~U[2023-12-26 20:16:00Z],
        tickets_count: 42,
        uuid: unique_sales_figures_uuid()
      })
      |> Bezirke.Sales.create_sales_figures()

    sales_figures
  end
end
