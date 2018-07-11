defmodule ShipchoiceBackend.Router do
  use ShipchoiceBackend, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ShipchoiceBackend.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShipchoiceBackend do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/shipments", ShipmentController, :index
    get "/shipments/upload", ShipmentController, :upload
    post "/shipments/upload", ShipmentController, :do_upload
    post "/shipments/:id/send_sms", ShipmentController, :send_sms

    get "/senders", SenderController, :index
    get "/senders/new", SenderController, :new
    post "/senders", SenderController, :create
    post "/senders/:id/send_sms_to_shipments", SenderController, :send_sms_to_shipments

    get "/t/:number", TrackingController, :tracking

    resources "/sessions", SessionController, only: [:new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShipchoiceBackend do
  #   pipe_through :api
  # end
end
