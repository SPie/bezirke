defmodule Bezirke.Tour do
  @moduledoc """
  The Tour context.
  """

  import Ecto.Query, warn: false
  alias Bezirke.Repo

  alias Bezirke.Tour.Production

  @doc """
  Returns the list of productions.

  ## Examples

      iex> list_productions()
      [%Production{}, ...]

  """
  def list_productions do
    Repo.all(Production)
  end

  @doc """
  Gets a single production.

  Raises `Ecto.NoResultsError` if the Production does not exist.

  ## Examples

      iex> get_production!(123)
      %Production{}

      iex> get_production!(456)
      ** (Ecto.NoResultsError)

  """
  def get_production!(id), do: Repo.get!(Production, id)

  def get_production_by_uuid!(uuid), do: Repo.get_by!(Production, uuid: uuid)

  @doc """
  Creates a production.

  ## Examples

      iex> create_production(%{field: value})
      {:ok, %Production{}}

      iex> create_production(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_production(attrs \\ %{}) do
    %Production{uuid: Repo.generate_uuid()}
    |> Production.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a production.

  ## Examples

      iex> update_production(production, %{field: new_value})
      {:ok, %Production{}}

      iex> update_production(production, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_production(%Production{} = production, attrs) do
    production
    |> Production.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a production.

  ## Examples

      iex> delete_production(production)
      {:ok, %Production{}}

      iex> delete_production(production)
      {:error, %Ecto.Changeset{}}

  """
  def delete_production(%Production{} = production) do
    Repo.delete(production)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking production changes.

  ## Examples

      iex> change_production(production)
      %Ecto.Changeset{data: %Production{}}

  """
  def change_production(%Production{} = production, attrs \\ %{}) do
    Production.changeset(production, attrs)
  end

  alias Bezirke.Tour.Performance

  @doc """
  Returns the list of performances.

  ## Examples

      iex> list_performances()
      [%Performance{}, ...]

  """
  def list_performances do
    Performance
    |> Repo.all()
    |> Repo.preload(:production)
    |> Repo.preload(:venue)
  end

  @doc """
  Gets a single performance.

  Raises `Ecto.NoResultsError` if the Performance does not exist.

  ## Examples

      iex> get_performance!(123)
      %Performance{}

      iex> get_performance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_performance!(id), do: Repo.get!(Performance, id)

  def get_performance_by_uuid!(uuid) do
    Performance
    |> Repo.get_by!(uuid: uuid)
    |> Repo.preload(:production)
    |> Repo.preload(:venue)
  end

  @doc """
  Creates a performance.

  ## Examples

      iex> create_performance(%{field: value})
      {:ok, %Performance{}}

      iex> create_performance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_performance(attrs) do
    # get production and venue id
    %Performance{uuid: Repo.generate_uuid()}
    |> Performance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a performance.

  ## Examples

      iex> update_performance(performance, %{field: new_value})
      {:ok, %Performance{}}

      iex> update_performance(performance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_performance(%Performance{} = performance, attrs) do
    performance
    |> Performance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a performance.

  ## Examples

      iex> delete_performance(performance)
      {:ok, %Performance{}}

      iex> delete_performance(performance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_performance(%Performance{} = performance) do
    Repo.delete(performance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking performance changes.

  ## Examples

      iex> change_performance(performance)
      %Ecto.Changeset{data: %Performance{}}

  """
  def change_performance(%Performance{} = performance, attrs \\ %{}) do
    production_uuid = get_product_uuid_from_performance(performance)
    venue_uuid = get_venue_uuid_from_performance(performance)

    Performance.changeset(performance, attrs)
    |> Ecto.Changeset.put_change(:production_uuid, production_uuid)
    |> Ecto.Changeset.put_change(:venue_uuid, venue_uuid)
  end

  defp get_product_uuid_from_performance(%Performance{production: %Production{uuid: uuid}}), do: uuid
  defp get_product_uuid_from_performance(%Performance{}), do: nil

  defp get_venue_uuid_from_performance(%Performance{venue: %Bezirke.Venues.Venue{uuid: uuid}}), do: uuid

  defp get_venue_uuid_from_performance(%Performance{}), do: nil
end
