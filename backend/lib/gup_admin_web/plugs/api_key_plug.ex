defmodule GupAdminWeb.Plugs.ApiKeyPlug do
  require Logger
  import Plug.Conn

  @behaviour Plug

  def init(options), do: options

  def call(conn, _opts) do
    api_key = conn.params["api_key"]
    if authenticate_api_key(api_key) do
      conn
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, ~s({"errors": {"be_authorization_error": "INVALID_OR_MISSING_API_KEY"}}))
      |> halt()
    end
  end

  def authenticate_api_key(nil), do: false
  def authenticate_api_key(api_key) do
    api_key == System.get_env("BACKEND_API_KEY")
  end
end
