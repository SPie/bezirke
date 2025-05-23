defmodule BezirkeWeb.Router do
  use BezirkeWeb, :router

  alias Bezirke.Tour

  pipeline :browser do
    plug :user_basic_auth
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

  defp user_basic_auth(conn, _opts) do
    conn
    |> Plug.BasicAuth.basic_auth(Application.fetch_env!(:bezirke, :basic_auth))
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
  end

  scope "/", BezirkeWeb do
    pipe_through :browser
    pipe_through :active_season

    resources "/productions", ProductionController, param: "uuid", except: [:index]
    live "/productions", ProductionsList

    get "/performances/:uuid", PerformanceController, :show
    get "/productions/:production_uuid/performances/new", PerformanceController, :new
    post "/productions/:production_uuid/performances", PerformanceController, :create
    live "/venues/:venue_uuid/performances", PerformanceNewForVenue
    post "/venues/:venue_uuid/performances", PerformanceController, :create
    get "/performances/:uuid/edit", PerformanceController, :edit
    put "/performances/:uuid", PerformanceController, :update
    delete "/performances/:uuid", PerformanceController, :delete
    post "/performances/:uuid/cancel", PerformanceController, :cancel
    post "/performances/:uuid/uncancel", PerformanceController, :uncancel

    get "/sales-figures/:uuid", SalesFiguresController, :show
    get "/productions/:production_uuid/sales-figures/new", SalesFiguresController, :new
    post "/productions/:production_uuid/sales-figures", SalesFiguresController, :create
    get "/sales-figures/:uuid/edit", SalesFiguresController, :edit
    put "/sales-figures/:uuid", SalesFiguresController, :update
    delete "/sales-figures/:uuid", SalesFiguresController, :delete
    get "/productions/:production_uuid/sales-figures/final/new", SalesFiguresController, :new_final
    post "/productions/:production_uuid/sales-figures/final", SalesFiguresController, :create_final

    resources "/events", EventController, param: "uuid"

    resources "/venues", VenueController, param: "uuid", except: [:show]
    live "/venues/:uuid", VenueShow

    get "/venues/:venue_uuid/seasons/:season_uuid/subscribers/new", SubscriberController, :new
    post "/venues/:venue_uuid/seasons/:season_uuid/subscribers", SubscriberController, :create
    get "/subscribers/:uuid/edit", SubscriberController, :edit
    put "/subscribers/:uuid", SubscriberController, :update

    live "/", ProductionSalesStatistics
    live "/statistics/performances", PerformanceSalesStatistics
    live "/statistics/venues", VenueSalesStatistics

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
