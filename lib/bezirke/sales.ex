defmodule Bezirke.Sales do
  @moduledoc """
  The Sales context.
  """

  import Ecto.Query, warn: false
  alias Bezirke.Repo

  alias Bezirke.Sales.SalesFigures

  @doc """
  Returns the list of sales_figures.

  ## Examples

      iex> list_sales_figures()
      [%SalesFigures{}, ...]

  """
  def list_sales_figures do
    SalesFigures
    |> Repo.all()
    |> Repo.preload([performance: [:production, :venue]])
  end

  @doc """
  Gets a single sales_figures.

  Raises `Ecto.NoResultsError` if the Sales figures does not exist.

  ## Examples

      iex> get_sales_figures!(123)
      %SalesFigures{}

      iex> get_sales_figures!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sales_figures!(id), do: Repo.get!(SalesFigures, id)

  def get_sales_figures_by_uuid!(uuid) do
    SalesFigures
    |> Repo.get_by!(uuid: uuid)
    |> Repo.preload([performance: [:production, :venue]])
  end

  @doc """
  Creates a sales_figures.

  ## Examples

      iex> create_sales_figures(%{field: value})
      {:ok, %SalesFigures{}}

      iex> create_sales_figures(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sales_figures(attrs \\ %{}) do
    %SalesFigures{uuid: Repo.generate_uuid()}
    |> SalesFigures.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sales_figures.

  ## Examples

      iex> update_sales_figures(sales_figures, %{field: new_value})
      {:ok, %SalesFigures{}}

      iex> update_sales_figures(sales_figures, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sales_figures(%SalesFigures{} = sales_figures, attrs) do
    sales_figures
    |> SalesFigures.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sales_figures.

  ## Examples

      iex> delete_sales_figures(sales_figures)
      {:ok, %SalesFigures{}}

      iex> delete_sales_figures(sales_figures)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sales_figures(%SalesFigures{} = sales_figures) do
    Repo.delete(sales_figures)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sales_figures changes.

  ## Examples

      iex> change_sales_figures(sales_figures)
      %Ecto.Changeset{data: %SalesFigures{}}

  """
  def change_sales_figures(%SalesFigures{} = sales_figures, attrs \\ %{}) do
    SalesFigures.changeset(sales_figures, attrs)
  end
end
