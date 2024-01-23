defmodule BezirkeWeb.ProductionSalesStatistics do
  use BezirkeWeb, :live_view

  alias Bezirke.Sales
  alias Bezirke.Tour

  def mount(_params, _session, socket) do
    seasons = Tour.list_seasons()

    production_statistics =
      seasons
      |> get_active_season()
      |> Tour.get_productions_for_season()
      |> Enum.map(&get_production_statistics/1)

    {labels, datasets} =
      production_statistics
      |> build_chart()

    socket =
      socket
      |> assign(seasons: get_seasons_options(seasons))
      |> assign(productions_statistics: production_statistics)
      |> assign(labels: labels)
      |> assign(datasets: datasets)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <.header>
        Production Sales Statistics
      </.header>
      <.input id="season" name="season" label="Season" type="select" options={@seasons} value="" />

      <div>
        <%= for production_statistic <- @productions_statistics do %>
          <div>
            <h2>
              <%= production_statistic.production.title %>
            </h2>
            <p>
              <%= production_statistic.tickets_count %>
                / <%= production_statistic.capacity %>
                (<%=  production_statistic.tickets_count / production_statistic.capacity * 100
                  |> Decimal.from_float()
                  |> Decimal.round(2)
                %> %)
            </p>
          </div>
        <% end %>
        <canvas
          id="production-sales"
          phx-hook="ChartJS"
          data-labels={Jason.encode!(@labels)}
        />
      </div>
    """
  end

  defp get_active_season(seasons) do
    case Enum.find(seasons, fn season -> season.active end) do
      nil -> List.first(seasons)
      active_season -> active_season
    end
  end

  defp get_seasons_options(seasons) do
    seasons
    |> Enum.map(fn season ->
      [
        key: season.name,
        value: season.uuid,
        selected: season.active,
      ]
    end)
  end

  defp get_production_statistics(production) do
    sales_figures = Sales.get_sales_figures_for_production(production)
    capacity = Tour.get_total_capacity(production)

    tickets_count =
      sales_figures
      |> Enum.reduce(
        0,
        fn %Sales.SalesFigures{tickets_count: tickets_count}, total_tickets_count ->
          total_tickets_count + tickets_count
        end
      )

    %{
      production: production,
      sales_figures: sales_figures,
      capacity: capacity,
      tickets_count: tickets_count,
    }
  end

  defp build_chart(production_statistics) do
    labels = get_labels(production_statistics)

    # build columns

    {labels, []}
  end

  defp get_labels(production_statistics) do
    sales_figures =
      production_statistics
      |> Enum.flat_map(fn %{sales_figures: sales_figures} ->
        Enum.map(sales_figures, &(DateTime.to_date(&1.record_date)))
      end)
      |> Enum.sort_by(&(&1), Date)

    start_date =
      sales_figures
      |> List.first()
      |> Date.add(-1)

    end_date =
      sales_figures
      |> List.last()
      |> Date.add(1)

    build_labels(start_date, end_date, [])
    |> Enum.reverse()
  end

  defp build_labels(current_date, end_date, labels) do
    case Date.compare(current_date, end_date) do
      :eq -> [current_date | labels]
      _ -> build_labels(Date.add(current_date, 1), end_date, [current_date | labels])
    end
  end

  defp build_dataset() do
  end

  defp build_chart1(production_statistics) do
    sorted_sales_figures = get_sorted_sales_figures(production_statistics)

    start =
      sorted_sales_figures
      |> List.first()
      |> elem(0)
      |> DateTime.add(-1, :day)

    initial_row =
      Tuple.duplicate(0, length(production_statistics))
      |> Tuple.insert_at(0, start)

    production_column_names =
      production_statistics
      |> Enum.map(fn %{production: production} -> production.title end)

    build_dataset1([initial_row], sorted_sales_figures)
    |> Contex.Dataset.new(["Date" | production_column_names])
    |> Contex.Plot.new(Contex.LinePlot, 600, 400, mapping: %{x_col: "Date", y_cols: production_column_names}, smoothed: false, legend_setting: :legend_right)
    |> Contex.Plot.to_svg()
  end

  defp get_sorted_sales_figures(production_statistics) do
    production_statistics
    |> Enum.with_index()
    |> Enum.flat_map(fn {%{sales_figures: sales_figures}, production_index} ->
      for sales_figure <- sales_figures, production_index do
        {
          DateTime.to_date(sales_figure.record_date),
          sales_figure.tickets_count,
          production_index,
        }
      end
    end)
    |> Enum.sort_by(&(elem(&1, 0)), Date)
  end

  defp build_dataset1(rows, []), do: rows |> Enum.reverse()

  defp build_dataset1([latest | past_rows] = rows, [{%DateTime{} = record_date, tickets_count, production_index} | tail]) do
    past_rows = case DateTime.compare(elem(latest, 0), record_date) do
      :eq -> past_rows
      _ -> rows
    end

    row =
      latest
      |> put_elem(
        0,
        record_date
      )
      |> put_elem(
        production_index + 1,
        elem(latest, production_index + 1) + tickets_count
      )

    build_dataset1([row | past_rows], tail)
  end
end
