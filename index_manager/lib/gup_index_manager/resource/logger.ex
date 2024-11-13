defmodule GupIndexManager.Resource.Logger do
  @error_log_file "error.log"
  @transaction_log_file "transaction.log"
  def log({:error, error, error_log_data}) do
    IO.inspect("logging error")
    now = DateTime.utc_now()
    {:ok, file} = File.open(@error_log_file, [:write, :append])
    IO.binwrite(file, "[error] #{now} error:#{error}\n data:#{inspect(error_log_data)}\n")
    File.close(file)
  end

  def log({:transaction, actions, data}) do
    now = DateTime.utc_now()
    {:ok, file} = File.open(@transaction_log_file, [:write, :append])
    IO.binwrite(file, "[info] #{now} actions: #{inspect(actions)}\n data: #{inspect(data)}\n")
    File.close(file)
  end
end
