defmodule BezirkeWeb.Router do
  use BezirkeWeb, :router

  import Plug.BasicAuth

  alias Bezirke.Tour

  pipeline :browser do
    plug :basic_auth, Application.compile_env(:bezirke, :basic_auth)
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BezirkeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :active_season do
    plug :set_active_season
    plug BezirkeWeb.Plugs.CheckActiveSeason
  end

  defp set_active_season(conn, _) do
    Tour.list_seasons()
    |> Tour.get_active_season()
    |> case do
      nil -> conn
      active_season -> assign(conn, :active_season, active_season.uuid)
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BezirkeWeb do
    pipe_through :browser

    resources "/seasons", SeasonController, param: "uuid"
    resources "/venues", VenueController, param: "uuid"
  end
  
  scope "/", BezirkeWeb do
    pipe_through :browser
    pipe_through :active_season

    resources "/productions", ProductionController, param: "uuid"

    get "/performances/:uuid", PerformanceController, :show
    get "/productions/:production_uuid/performances/new", PerformanceController, :new
    post "/productions/:production_uuid/performances", PerformanceController, :create
    get "/performances/:uuid/edit", PerformanceController, :edit
    put "/performances/:uuid", PerformanceController, :update
    delete "/performances/:uuid", PerformanceController, :delete

    get "/sales-figures/:uuid", SalesFiguresController, :show
    get "/performances/:performance_uuid/sales-figures/new", SalesFiguresController, :new
    post "/performances/:performance_uuid/sales-figures", SalesFiguresController, :create
    get "/sales-figures/:uuid/edit", SalesFiguresController, :edit
    put "/sales-figures/:uuid", SalesFiguresController, :update
    delete "/sales-figures/:uuid", SalesFiguresController, :delete

    live "/", ProductionSalesStatistics
  end

  # Other scopes may use custom stacks.
  # scope "/api", BezirkeWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:bezirke, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BezirkeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
