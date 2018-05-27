defmodule ShipchoiceBackend.Router do
  use ShipchoiceBackend, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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

    get "/senders", SenderController, :index
    get "/senders/new", SenderController, :new
    post "/senders", SenderController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShipchoiceBackend do
  #   pipe_through :api
  # end
end
