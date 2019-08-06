defmodule Blockchain.Record do
  use Agent
  defstruct name: "", date: nil, text: ""

  @spec start_link(List) :: :ok
  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @spec add_record(Blockchain.Record) :: :ok
  def add_record(record) do
    record_list =
      Agent.get(__MODULE__, fn list -> list end) ++
        [record]

    Agent.update(__MODULE__, fn _ -> record_list end)
  end

  @spec get_records() :: {:ok, [Record]} | {:error, :empty}
  def get_records() do
    case Agent.get(__MODULE__, fn records -> records end) do
      [] -> {:error, :empty}
      records -> {:ok, records}
    end
  end

  @spec get_three_records() :: {:ok, [Record]} | {:error, :no_minimum_records}
  def get_three_records() do
    case Agent.get(__MODULE__, fn records -> records end) do
      records when length(records) > 2 -> {:ok, remove_elements(records)}
      _ -> {:error, :no_minimum_records}
    end
  end

  @spec refound_three_records([Records]) :: :ok
  def refound_three_records(records) do
    Agent.update(__MODULE__, fn tail -> records ++ tail end)
    IO.inspect("REFOUNDED")
  end

  defp remove_elements(records) do
    [first, second, third | other_records] = records
    Agent.update(__MODULE__, fn _ -> other_records end)
    [first, second, third]
  end
end

defimpl Jason.Encoder, for: Blockchain.Record do
  def encode(value, opts) do
    Jason.Encode.map(Map.take(value, [:name, :date, :text]), opts)
  end
end
