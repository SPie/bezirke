defmodule Bezirke.Sales do
  @moduledoc """
  The Sales context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Bezirke.Repo

  alias Bezirke.Sales.MultiSalesFigures
  alias Bezirke.Sales.SalesFigures
  alias Bezirke.Tour.Performance
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
    SalesFigures
    |> Repo.get_by!(uuid: uuid)
    |> Repo.preload([performance: [:production, :venue]])
  end

  def create_multi_sales_figures(attrs) do
    %MultiSalesFigures{}
    |> MultiSalesFigures.changeset(attrs)
    |> Map.replace(:action, :insert)
    |> handle_multi_sales_figures_changeset()
  end

  def create_final_sales_figures(attrs) do
    %MultiSalesFigures{}
    |> MultiSalesFigures.changeset_final(attrs)
    |> Map.replace(:action, :insert)
    |> handle_final_sales_figures_changeset()
  end

  defp handle_multi_sales_figures_changeset(%Ecto.Changeset{valid?: false} = changeset),
    do: {:error, changeset}

  defp handle_multi_sales_figures_changeset(changeset) do
    changeset
    |> Ecto.Changeset.get_change(:sales_figures)
    |> Enum.filter(fn sales_figures_changeset ->
      tickets_count = Ecto.Changeset.get_change(sales_figures_changeset, :tickets_count)

      tickets_count != nil and tickets_count != 0 and tickets_count != ""
    end)
    |> handle_sales_figures_transactions()
  end

  defp handle_final_sales_figures_changeset(%Ecto.Changeset{valid?: false} = changeset),
    do: {:error, changeset}

  defp handle_final_sales_figures_changeset(changeset) do
    changeset
    |> Ecto.Changeset.get_change(:sales_figures)
    |> handle_sales_figures_transactions()
  end

  defp handle_sales_figures_transactions(sales_figures_changeset) do
    sales_figures_changeset
    |> Enum.reduce(Multi.new(), fn sales_figures_changeset, multi ->
      multi
      |> Multi.merge(fn _ -> insert_sales_figures(sales_figures_changeset) end)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, new_sales_figures} -> {:ok, new_sales_figures}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  defp insert_sales_figures(changeset) do
    uuid = Ecto.Changeset.get_change(changeset, :uuid)
    insert_key = "insert_sales_figures_" <> uuid
    future_key = "future_sales_figures_" <> uuid
    update_key = "updated_future_sales_figure_" <> uuid

    Multi.new()
    |> Multi.insert(insert_key, changeset)
    |> Multi.run(future_key, fn (repo, %{^insert_key => %SalesFigures{performance_id: performance_id, record_date: record_date}}) ->
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
    |> Multi.merge(fn %{^insert_key => %SalesFigures{tickets_count: tickets_count}, ^future_key => future_sales_figures} ->
      case future_sales_figures do
        nil -> Multi.new()
        %SalesFigures{tickets_count: current_tickets_count} = future_sales_figure ->
          Multi.new()
          |> Multi.update(update_key, Ecto.Changeset.change(future_sales_figure, tickets_count: current_tickets_count + tickets_count * (-1)))
      end
    end)
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
    changeset =
      sales_figures
      |> SalesFigures.changeset_for_update(attrs)

    Multi.new()
    |> Multi.update(:updated_sales_figures, changeset)
    |> Multi.run(:future_sales_figures, fn (repo, %{updated_sales_figures: %SalesFigures{performance_id: performance_id, record_date: record_date}}) ->
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
    |> Multi.merge(fn %{updated_sales_figures: %SalesFigures{tickets_count: tickets_count}, future_sales_figures: future_sales_figures} ->
      case future_sales_figures do
        nil -> Multi.new()
        %SalesFigures{tickets_count: current_tickets_count} = future_sales_figure ->
          Multi.new()
          |> Multi.update(:updated_future_sales_figure, Ecto.Changeset.change(future_sales_figure, tickets_count: current_tickets_count + (sales_figures.tickets_count - tickets_count)))
      end
    end)
    |> Repo.transaction()
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

  def change_multi_sales_figures(%MultiSalesFigures{} = multi_sales_figures, performances) do
    sales_figures =
      performances
      |> Enum.map(fn %Performance{} = performance ->
        SalesFigures.changeset_multi(
          %SalesFigures{performance: performance, performance_uuid: performance.uuid},
          %{}
        )
      end)

    multi_sales_figures
    |> MultiSalesFigures.changeset(%{})
    |> Ecto.Changeset.put_embed(:sales_figures, sales_figures)
  end

  def change_final_sales_figures(%MultiSalesFigures{} = multi_sales_figures, performances) do
    sales_figures =
      performances
      |> Enum.map(fn %Performance{} = performance ->
        SalesFigures.changeset_multi_final(
          %SalesFigures{performance: performance, performance_uuid: performance.uuid},
          %{}
        )
      end)

    multi_sales_figures
    |> MultiSalesFigures.changeset(%{})
    |> Ecto.Changeset.put_embed(:sales_figures, sales_figures)
  end

  def change_sales_figures_for_update(%SalesFigures{} = sales_figures, attrs \\ %{}) do
    SalesFigures.changeset_for_update(sales_figures, attrs)
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

  def get_current_tickets_count_for_performance(performance, current_record_date, nil) do
    from(
      s in SalesFigures,
      join: pf in assoc(s, :performance),
      where: pf.id == ^performance.id,
      where: s.record_date <= ^current_record_date,
      select: sum(s.tickets_count)
    )
    |> Repo.one!()
    |> case do
      nil -> 0
      tickets_count -> tickets_count
    end
  end

  def get_current_tickets_count_for_performance(performance, current_record_date, sales_figures_id) do
    from(
      s in SalesFigures,
      join: pf in assoc(s, :performance),
      where: pf.id == ^performance.id,
      where: s.record_date < ^current_record_date,
      where: s.id != ^sales_figures_id,
      select: sum(s.tickets_count)
    )
    |> Repo.one!()
    |> case do
      nil -> 0
      tickets_count -> tickets_count
    end
  end

  def get_sales_figures_for_performance(%Performance{id: performance_id}) do
    from(
      s in SalesFigures,
      where: s.performance_id == ^performance_id,
      order_by: s.record_date
    )
    |> Repo.all()
  end

  def get_sales_figures_with_tickets_count_sum(performance) do
    get_sales_figures_for_performance(performance)
    |> sum_tickets_count_for_sales_figures(0, [])
  end

  defp sum_tickets_count_for_sales_figures([], _, sales_figures_with_tickets_count),
    do: sales_figures_with_tickets_count

  defp sum_tickets_count_for_sales_figures(
    [%SalesFigures{tickets_count: tickets_count} = current_sales_figure | next_sales_figures],
    tickets_count_sum,
    sales_figures_with_tickets_count
  ) do
    tickets_count_sum = tickets_count_sum + tickets_count

    sum_tickets_count_for_sales_figures(
      next_sales_figures,
      tickets_count_sum,
      [{current_sales_figure, tickets_count_sum} | sales_figures_with_tickets_count]
    )
  end
end
