defmodule GupAdminWeb.IndexController do
  use GupAdminWeb, :controller

  def index(conn, _params) do
      Experiment.init()
    json conn, %{message: "index done"}
  end
end
