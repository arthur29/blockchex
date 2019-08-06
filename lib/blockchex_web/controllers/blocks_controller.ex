defmodule BlocksController do
  alias Blockchain.Blockchain
  use BlockchexWeb, :controller

  def index(conn, _opts) do
    case Blockchain.get_blockchain() do
      {:ok, blockchain} -> json(conn, blockchain)
      {:error, :empty} -> send_resp(conn, 204, "")
    end
  end

  def mine(conn, _opts) do
    case Blockchain.mine_records() do
      {:error, :no_minimum_to_mine} -> send_resp(conn, 500, "No minimum records to mine a block")
      {:error, :invalid_block_insertion} -> send_resp(conn, 500, "Invalid block insertion")
      {:ok, block} -> json(conn, block)
    end
  end
end
