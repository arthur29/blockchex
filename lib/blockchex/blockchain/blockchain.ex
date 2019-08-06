defmodule Blockchain.Blockchain do
  use Agent

  alias Blockchain.Record
  alias Blockchain.Block

  @spec start_link(List) :: :ok
  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @spec get_blockchain() :: {:ok, [Block]} | {:error, :empty}
  def get_blockchain() do
    blockchain = Agent.get(__MODULE__, fn blockchain -> blockchain end)

    cond do
      length(blockchain) == 0 -> {:error, :empty}
      true -> {:ok, blockchain}
    end
  end

  @spec mine_records() ::
          {:error, :no_minimum_to_mine} | {:error, :invalid_block_insertion} | {:ok, Block}
  def mine_records() do
    case Record.get_three_records() do
      {:error, :no_minimum_records} -> {:error, :no_minimum_to_mine}
      {:ok, records} -> processes_mining(records)
    end
  end

  defp processes_mining(records) do
    with block <- create_block(records),
         block <- Block.mine(block),
         {:ok, block} <- insert_on_blockchain(block) do
      {:ok, block}
    else
      {:error, reason} ->
        Record.refound_three_records(records)
        {:error, reason}
    end
  end

  defp insert_on_blockchain(block) do
    with {:ok, blockchain} <- get_blockchain(),
         blockchain <- blockchain ++ [block],
         true <- valid?(blockchain) do
      Agent.update(__MODULE__, fn _old_blockchain -> blockchain end)
      {:ok, block}
    else
      {:error, :empty} ->
        if Block.valid?(block) do
          Agent.update(__MODULE__, fn _old -> [block] end)
          {:ok, block}
        else
          {:error, :invalid_block_insertion}
        end

      false ->
        {:error, :invalid_block_insertion}
    end
  end

  defp valid?(blockchain, previous_block_hash \\ nil) do
    case List.first(blockchain) do
      # To be nil block it have two options
      # 1) the blockchain is clean so the blockchain is valid -> true
      # 2) the block is nil and previous_block_hash is not, the function is on the final of blockchain and all blocks is valid -> true
      block when is_nil(block) ->
        true

      block when not is_nil(block) and is_nil(previous_block_hash) ->
        [_head | tail] = blockchain
        Block.valid?(block) && valid?(tail, block.hash)

      block when not is_nil(block) and not is_nil(previous_block_hash) ->
        if block.hash == previous_block_hash do
          [_head | tail] = blockchain
          Block.valid?(block) && valid?(tail, block.hash)
        else
          IO.inspect("#{block.hash} #{previous_block_hash}")
          false
        end
    end
  end

  defp create_block(records) do
    %Block{}
    |> Block.insert_records(records)
    |> Map.put(:previous_block_hash, fetch_last_block_hash())
  end

  defp fetch_last_block_hash() do
    with {:ok, blockchain} <- get_blockchain(),
         last_block when not is_nil(last_block) <- List.last(blockchain),
         hash <- Map.get(last_block, :previous_block_hash) do
      hash
    else
      _ -> :crypto.hash(:sha256, "Arthur") |> Base.encode64()
    end
  end
end
