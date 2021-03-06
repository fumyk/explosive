defmodule Dictionary do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: {:global, :dict_server})
  end

  def child_spec(_init_arg \\ []) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  @impl true
  def init(_init_arg) do
    set = :gb_sets.new()

    filled_set =
      File.read!("cfg/words.txt")
      |> String.split()
      |> List.foldl(set, fn e, acc -> :gb_sets.add(e, acc) end)

    {:ok, filled_set}
  end

  @impl true
  def handle_call({:ask, key}, _from, state) do
    ans = :gb_sets.is_element(key, state)
    {:reply, ans, state}
  end

  @spec check(binary()) :: boolean()
  def check(word) do
    GenServer.call({:global, :dict_server}, {:ask, word})
  end
end
