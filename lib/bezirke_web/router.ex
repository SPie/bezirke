defmodule BezirkeWeb.Router do
  use BezirkeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BezirkeWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BezirkeWeb do
    pipe_through :browser

    # Placeholder
    get "/", PerformanceController, :index

    resources "/productions", ProductionController, param: "uuid"
    resources "/venues", VenueController, param: "uuid"
    resources "/performances", PerformanceController, param: "uuid"
    resources "/sales-figures", SalesFiguresController, param: "uuid"
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
