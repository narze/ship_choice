defmodule ShipchoiceBackend.Router do
  use ShipchoiceBackend, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(ShipchoiceBackend.Auth)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ShipchoiceBackend do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    get("/dashboard", DashboardController, :index)

    get("/shipments", ShipmentController, :index)
    get("/shipments/upload", ShipmentController, :upload)
    post("/shipments/upload", ShipmentController, :do_upload)
    post("/shipments/:id/send_message", ShipmentController, :send_message)

    resources("/senders", SenderController, only: [:index, :new, :create, :show]) do
      resources("/credits", CreditController, only: [:new, :create])
    end
    post("/senders/:id/send_message_to_shipments", SenderController, :send_message_to_shipments)

    get("/messages", MessageController, :index)

    get("/t/:number", TrackingController, :tracking)

    resources("/memberships", MembershipController, only: [:new, :create])
    resources("/sessions", SessionController, only: [:new, :create, :delete])
    resources("/users", UserController, only: [:index, :new, :create])
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShipchoiceBackend do
  #   pipe_through :api
  # end
end
