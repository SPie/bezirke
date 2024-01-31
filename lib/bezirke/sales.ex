defmodule Bezirke.Sales do
  @moduledoc """
  The Sales context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Bezirke.Repo

  alias Bezirke.Sales.SalesFigures
  alias Bezirke.Tour.Production

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
    sales_figures =
      SalesFigures
      |> Repo.get_by!(uuid: uuid)
      |> Repo.preload([performance: [:production, :venue]])


    current_tickets_count = get_current_tickets_count_for_performance(
      sales_figures.performance,
      sales_figures.record_date
    )

    %SalesFigures{sales_figures | tickets_count: current_tickets_count + sales_figures.tickets_count}
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
    sales_figure =
      %SalesFigures{uuid: Repo.generate_uuid()}
      |> SalesFigures.changeset(attrs)

    Multi.new()
    |> Multi.insert(:new_sales_figures, sales_figure)
    |> Multi.run(:future_sales_figures, fn (repo, %{new_sales_figures: %SalesFigures{performance_id: performance_id, record_date: record_date}}) ->
      future_sales_figures =
        from(
          s in SalesFigures,
          where: s.record_date > ^record_date,
          where: s.performance_id == ^performance_id,
          order_by: s.record_date
        )
        |> repo.all()
        |> List.first()

      {:ok, future_sales_figures}
    end)
    |> Multi.merge(fn %{new_sales_figures: %SalesFigures{tickets_count: tickets_count}, future_sales_figures: future_sales_figures} ->
      case future_sales_figures do
        nil -> Multi.new()
        %SalesFigures{tickets_count: current_tickets_count} = future_sales_figure ->
          Multi.new()
          |> Multi.update(:updated_sales_figure, Ecto.Changeset.change(future_sales_figure, tickets_count: current_tickets_count + tickets_count * (-1)))
      end
    end)
    |> Repo.transaction()
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

  def get_sales_figures_for_production(%Production{id: production_id}) do
    from(
      s in SalesFigures,
      join: pf in assoc(s, :performance),
      join: p in assoc(pf, :production),
      where: p.id == ^production_id,
      order_by: s.record_date
    )
    |> Repo.all()
  end

  def get_current_tickets_count_for_performance(performance, current_record_date) do
    from(
      s in SalesFigures,
      join: pf in assoc(s, :performance),
      where: pf.id == ^performance.id,
      where: s.record_date < ^current_record_date,
      select: sum(s.tickets_count)
    )
    |> Repo.one!()
  end
end
