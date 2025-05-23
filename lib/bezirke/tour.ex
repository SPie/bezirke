defmodule Bezirke.Tour do
  @moduledoc """
  The Tour context.
  """

  import Ecto.Query, warn: false

  alias Bezirke.Repo
  alias Bezirke.Tour.Season
  alias Bezirke.Tour.Production
  alias Bezirke.Tour.Performance
  alias Bezirke.Tour.Subscriber
  alias Bezirke.Venues
  alias Bezirke.Venues.Venue

  @doc """
  Returns the list of productions.

  ## Examples

      iex> list_productions()
      [%Production{}, ...]

  """
  def list_productions do
    Production
    |> Repo.all()
    |> Repo.preload([:season])
  end

  def get_productions_for_season(%Season{id: season_id}) do
    from(p in Production, where: p.season_id == ^season_id)
    |> Repo.all()
    |> Repo.preload([:season])
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

  def get_production_by_uuid!(uuid) do
    Production
    |> Repo.get_by!(uuid: uuid)
    |> Repo.preload([:season])
  end

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
    season_uuid = get_season_uuid_from_production(production)

    Production.changeset(production, attrs)
    |> Ecto.Changeset.put_change(:season_uuid, season_uuid)
  end

  defp get_season_uuid_from_production(%Production{season: %Season{uuid: uuid}}), do: uuid
  defp get_season_uuid_from_production(%Production{}), do: nil

  def get_total_capacity(%Production{id: id}) do
    from(
      p in Production,
      join: pf in assoc(p, :performances),
      select: sum(pf.capacity),
      where: p.id == ^id,
      where: is_nil(pf.cancelled_at)
    )
    |> Repo.one()
    |> case do
      nil -> 0
      capacity -> capacity
    end
  end

  @doc """
  Returns the list of performances.

  ## Examples

      iex> list_performances()
      [%Performance{}, ...]

  """
  def list_performances do
    Performance
    |> Repo.all()
    |> Repo.preload([:production, :venue])
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
    |> Repo.preload([:production, :venue])
  end

  def get_performance_by_uuid(uuid) do
    Performance
    |> Repo.get_by(uuid: uuid)
  end

  def get_performances_for_production(%Production{id: production_id}) do
    from(
      pf in Performance,
      where: pf.production_id == ^production_id,
      order_by: pf.played_at
    )
    |> Repo.all()
    |> Repo.preload(:venue)
  end

  def get_performances_for_production_with_sales_figures(production) do
    get_performances_for_production(production)
    |> Repo.preload(:sales_figures)
  end

  def get_performances_for_venue(%Venue{id: venue_id}) do
    from(
      pf in Performance,
      where: pf.venue_id == ^venue_id
    )
    |> Repo.all()
    |> Repo.preload(:production)
  end

  def get_performances_for_venue_and_season(
    %Venue{id: venue_id},
    %Season{id: season_id}
  ) do
    from(
      pf in Performance,
      join: p in assoc(pf, :production),
      where: pf.venue_id == ^venue_id,
      where: p.season_id == ^season_id
    )
    |> Repo.all()
    |> Repo.preload(:production)
  end

  def get_performances_for_venue_and_season_with_sales_figures(
    %Venue{id: venue_id},
    %Season{id: season_id}
  ) do
    from(
      pf in Performance,
      join: p in assoc(pf, :production),
      where: pf.venue_id == ^venue_id,
      where: p.season_id == ^season_id
    )
    |> Repo.all()
    |> Repo.preload([:sales_figures, :production])
  end

  def create_performance({:production, production_uuid}, attrs) do
    %Performance{production: get_production_by_uuid!(production_uuid)}
    |> do_create_performance(attrs)
  end

  def create_performance({:venue, venue_uuid}, attrs) do
    %Performance{venue: Venues.get_venue_by_uuid!(venue_uuid)}
    |> do_create_performance(attrs)
  end

  defp do_create_performance(%Performance{} = performance, attrs) do
    performance
    |> Map.put(:uuid, Repo.generate_uuid())
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

  def cancel_performance(%Performance{} = performance) do
    performance
    |> Performance.cancel(%{"cancelled_at" => DateTime.utc_now()})
    |> Repo.update()
  end

  def uncancel_performance(%Performance{} = performance) do
    performance
    |> Performance.cancel(%{"cancelled_at" => nil})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking performance changes.

  ## Examples

      iex> change_performance(performance)
      %Ecto.Changeset{data: %Performance{}}

  """
  def change_performance(%Performance{} = performance, attrs \\ %{}) do
    case performance.played_at do
      nil -> performance |> Map.put(:played_at_time, Time.new!(19, 30, 0))
      played_at ->
        performance
        |> Map.put(:played_at_date, DateTime.to_date(played_at))
        |> Map.put(:played_at_time, DateTime.to_time(played_at))
    end
    |> Performance.changeset(attrs)
    |> Ecto.Changeset.put_change(:venue_uuid, performance.venue_uuid)
  end

  @doc """
  Returns the list of seasons.

  ## Examples

      iex> list_seasons()
      [%Season{}, ...]

  """
  def list_seasons do
    Repo.all(Season)
  end

  @doc """
  Gets a single season.

  Raises `Ecto.NoResultsError` if the Season does not exist.

  ## Examples

      iex> get_season!(123)
      %Season{}

      iex> get_season!(456)
      ** (Ecto.NoResultsError)

  """
  def get_season!(id), do: Repo.get!(Season, id)

  def get_season_by_uuid!(uuid), do: Repo.get_by!(Season, uuid: uuid)

  @doc """
  Creates a season.

  ## Examples

      iex> create_season(%{field: value})
      {:ok, %Season{}}

      iex> create_season(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_season(attrs \\ %{}) do
    %Season{uuid: Repo.generate_uuid()}
    |> Season.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a season.

  ## Examples

      iex> update_season(season, %{field: new_value})
      {:ok, %Season{}}

      iex> update_season(season, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_season(%Season{} = season, attrs) do
    season
    |> Season.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a season.

  ## Examples

      iex> delete_season(season)
      {:ok, %Season{}}

      iex> delete_season(season)
      {:error, %Ecto.Changeset{}}

  """
  def delete_season(%Season{} = season) do
    Repo.delete(season)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking season changes.

  ## Examples

      iex> change_season(season)
      %Ecto.Changeset{data: %Season{}}

  """
  def change_season(%Season{} = season, attrs \\ %{}) do
    Season.changeset(season, attrs)
  end

  def get_active_season(seasons) do
    seasons
    |> Enum.find(fn season -> season.active end)
    |> case do
      nil -> List.first(seasons)
      active_season -> active_season
    end
  end

  def get_subscriber_by_uuid!(uuid) do
    Subscriber
    |> Repo.get_by!(uuid: uuid)
    |> Repo.preload([:venue, :season])
  end

  def get_subscriber_for_venue_and_season(
    %Venue{id: venue_id},
    %Season{id: season_id}
  ) do
    from(
      sub in Subscriber,
      where: sub.venue_id == ^venue_id,
      where: sub.season_id == ^season_id
    )
    |> Repo.one()
  end

  def create_subscriber(venue, season, attrs \\ %{}) do
    %Subscriber{
      uuid: Repo.generate_uuid(),
      venue: venue,
      season: season
    }
    |> Subscriber.changeset(attrs)
    |> Repo.insert()
  end

  def update_subscriber(subscriber, attrs \\ %{}) do
    subscriber
    |> Subscriber.changeset(attrs)
    |> Repo.update()
  end

  def change_subscriber(%Subscriber{} = subscriber, attrs \\ %{}) do
    Subscriber.changeset(subscriber, attrs)
  end

  def get_total_subscribers_for_season(%Season{id: season_id}) do
    from(
      sub in Subscriber,
      select: sum(sub.quantity),
      where: sub.season_id == ^season_id
    )
    |> Repo.one()
    |> case do
      nil -> 0
      quantity -> quantity
    end
  end
end
