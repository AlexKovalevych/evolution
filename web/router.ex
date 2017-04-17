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

    get "/login", AuthController, :login, as: :login
    post "/login", AuthController, :login
    get "/signup", AuthController, :signup, as: :signup
    post "/signup", AuthController, :signup
    get "/*path", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Evolution do
  #   pipe_through :api
  # end
end
