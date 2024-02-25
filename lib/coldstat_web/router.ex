defmodule ColdstatWeb.Router do
  use ColdstatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ColdstatWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :x_sig_auth do
    plug :accepts, ["json"]
    plug ColdstatWeb.Plugs.Idempotency
    plug ColdstatWeb.Plugs.XSigAuth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ColdstatWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api/", ColdstatWeb do
    pipe_through :x_sig_auth

    get "/user_balance/:user_id", BalanceController, :show
    post "/user_balance/win", BalanceController, :credit_transaction
    post "/user_balance/lose", BalanceController, :debit_transaction
  end

  # Other scopes may use custom stacks.
  # scope "/api", ColdstatWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ColdstatWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
