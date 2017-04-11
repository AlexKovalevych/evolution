defmodule Evolution.Router do
  use Evolution.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Evolution do
    pipe_through [:browser, :browser_session] # Use the default browser stack

    get "/login", AuthController, :auth, as: :login
    get "/signup", AuthController, :auth, as: :signup
    get "/*path", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Evolution do
  #   pipe_through :api
  # end
end
