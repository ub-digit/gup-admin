defmodule GupAdminWeb.Router do
  use GupAdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GupAdminWeb.LayoutView, :root}
    #plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug GupAdminWeb.ParamPlug, %{
      "scopus" => :boolean,
      "gup" => :boolean,
      "wos" => :boolean,
      "manual" => :boolean,
      "year" => :integer,
      "needs_attention" => :boolean,
    }
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug GupAdminWeb.Plugs.ApiKeyPlug
  end

  scope "/", GupAdminWeb do
    pipe_through :browser

    get "/publication_types", PublicationTypeController, :index
    get "/publications", PublicationController, :index
    get "/publications/:id", PublicationController, :show
    get "/publications/:id/authors", PublicationController, :show_authors
    delete "/publications/:id", PublicationController, :delete
    get "/publications/duplicates/:id", PublicationController, :get_duplicates
    get "/index", IndexController, :index
    post "/publications/post_to_gup/:id/:gup_user", PublicationController, :post_to_gup
    get "/publications/compare/imported_id/:imported_id/gup_id/:gup_id", PublicationController, :compare
    post "/publications/merge/:publication_id/:gup_id/:gup_user", PublicationController, :merge_publications
    get "/departments", DepartmentController, :get_departments
    # get "/persons", PersonController, :search
    get "/persons/:id", PersonController, :get_one


  end

  scope "/api", GupAdminWeb do
    pipe_through :api
    get    "/person_id_codes", PersonController, :get_id_codes
    post   "/persons"        , PersonController, :create
    get    "/persons"        , PersonController, :search
    put    "/persons/:id"    , PersonController, :update
    get    "/persons/:id"    , PersonController, :show
    delete "/persons/:id"    , PersonController, :delete
  end

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

      live_dashboard "/dashboard", metrics: GupAdminWeb.Telemetry
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
