defmodule Blockchain.Block do
  require Logger
  defstruct previous_block_hash: nil, data: %{nonce: 0, records: []}, hash: nil

  @spec mine(Block) :: Block
  def mine(block) do
    Logger.info("nonce: #{block.data[:nonce]}")
    with hash <- generate_hash(block),
         block <- Map.put(block, :hash, hash),
         false <- valid?(block),
         data <- block.data,
         data <- Map.put(data, :nonce, data.nonce + 1),
         block <- Map.put(block, :data, data) do
      mine(block)
    else
      true -> Map.put(block, :hash, generate_hash(block))
    end
  end

  @spec insert_records(Block, [Record]) :: Block
  def insert_records(block, records) do
    data = block.data
    data = Map.put(data, :records, records)
    Map.put(block, :data, data)
  end

  @spec generate_hash(Block) :: String.t()
  def generate_hash(block) do
    {:ok, json_block} = Poison.encode(block.data)

    :crypto.hash(:sha256, json_block)
    |> Base.encode64()
  end

  @spec valid?(Block) :: true | false
  def valid?(block) do
    {:ok, decoded_hash} = Base.decode64(block.hash)

    decoded_hash
    |> :binary.bin_to_list()
    |> Enum.count(fn caracter -> caracter == 0 end)
    |> has_minimum_zeros_on_hash?()
  end

  defp has_minimum_zeros_on_hash?(num) do
    if num > 4 do
      true
    else
      false
    end
  end
end

defimpl Jason.Encoder, for: Blockchain.Block do
  def encode(value, opts) do
    Jason.Encode.map(Map.take(value, [:previous_block_hash, :data, :hash]), opts)
  end
end
