defmodule DistributedPrimes do
  def calculate(n) when n > 1 do
    nodes = [Node.self() | Node.list()]
    chunk_size = div(n, length(nodes))
    ranges = for i <- 0..(length(nodes) - 1), do: {i * chunk_size + 1, min((i + 1) * chunk_size, n)}

    nodes
    |> Enum.zip(ranges)
    |> Enum.map(fn {node, range} ->
      Task.async(fn -> :erpc.call(node, __MODULE__, :primes_in_range, [range]) end)
    end)
    |> Task.await_many(:infinity)
    |> List.flatten()
  end

  def primes_in_range({low, high}) do
    Enum.filter(low..high, &is_prime?/1)
  end

  defp is_prime?(2), do: true
  defp is_prime?(n) when n < 2 or rem(n, 2) == 0, do: false
  defp is_prime?(n) do
    3
    |> Stream.iterate(&(&1 + 2))
    |> Enum.take_while(&(&1 * &1 <= n))
    |> Enum.all?(fn x -> rem(n, x) != 0 end)
  end
end
