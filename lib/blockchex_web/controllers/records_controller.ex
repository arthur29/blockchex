defmodule RecordsController do
  use BlockchexWeb, :controller
  alias Blockchain.Record

  def create(conn,%{"name" => name, "text" => text}) do
    case Record.add_record(%Record{name: name, text: text, datetime: DateTime.utc_now()}) do
      :ok -> send_resp(conn, 201, "record created successful\n")
      error -> send_resp(conn, 500, error)
    end
  end

  def pending(conn, _opts) do
    case Record.get_records() do
      {:ok,registers} -> json(conn, registers)
      {:error, :empty} -> send_resp(conn, 204, "")
    end
  end
end
