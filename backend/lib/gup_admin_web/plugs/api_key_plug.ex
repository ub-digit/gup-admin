defmodule GupAdminWeb.Plugs.ApiKeyPlug do
  require Logger
  import Plug.Conn

  @behaviour Plug

  def init(options), do: options

  def call(conn, _opts) do
    api_key = conn.params["api_key"]
    case authenticate_api_key(api_key) do
      :ok ->
        conn
      :error ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:unauthorized, ~s({"errors": {"be_authorization_error": "INVALID_OR_MISSING_API_KEY"}}))
        |> halt()
    end
  end

  def authenticate_api_key(nil), do: :error
  def authenticate_api_key(api_key) do
    expected_api_key = get_api_key_be()
    ok(api_key == expected_api_key)
  end

  def ok(true), do: :ok
  def ok(false), do: :error

  def get_api_key_be(), do: System.get_env("ADMIN_BACKEND_API_KEY")

end
