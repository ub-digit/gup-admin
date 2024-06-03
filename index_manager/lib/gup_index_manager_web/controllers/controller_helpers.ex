defmodule GupIndexManagerWeb.ControllerHelpers do

  def check_api_key(nil) do
    false
  end

  def check_api_key(api_key) do
    case Mix.env() do
      :dev -> true
      _ -> api_key == get_api_key()
    end
  end

  defp get_api_key() do
    System.get_env("GUP_INDEX_MANAGER_API_KEY")
  end
end
