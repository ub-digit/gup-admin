defmodule GupIndexManager.Resource.Logger do
  @error_log_file "error.log"
  @transactions_log_file "transaction.log"
  def log({:error, error, error_log_data}) do
    file_path = System.get_env("ERROR_LOG_FILE_PATH") || @error_log_file
    now = DateTime.utc_now()
    {:ok, file} = File.open(file_path, [:write, :append])
    IO.binwrite(file, "[error] #{now} error:#{error}\n data:#{inspect(error_log_data)}\n")
    File.close(file)
  end

  def log({:transaction, actions, data}) do
    file_path = System.get_env("TRANSACTIONS_LOG_FILE_PATH") || @transactions_log_file
    now = DateTime.utc_now()
    {:ok, file} = File.open(file_path, [:write, :append])
    IO.binwrite(file, "[info] #{now} actions: #{inspect(actions)}\n data: #{inspect(data)}\n")
    File.close(file)
  end
end
