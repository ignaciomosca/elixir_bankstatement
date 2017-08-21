defmodule Budget do

  alias NimbleCSV.RFC4180, as: CSV

  def list_transactions do
    case File.read("lib/transactions.csv") do
      {:ok, body} -> body |> parse |> filter |> normalize |> sort |> print
      {:error, reason} -> reason
    end
  end

  defp parse(body) do
    body |> String.replace("\r", "") |>  CSV.parse_string
  end

  defp filter(rows) do
    Enum.map(rows, &Enum.drop(&1, 1))
  end

  defp normalize(rows) do
    Enum.map(rows, &parse_amount(&1))
  end

  defp parse_amount([date, description, amount]) do
    [date, description, parse_to_float(amount)]
  end

  defp parse_to_float(amount) do
    amount |> String.to_float |> abs
  end

  defp sort(rows) do
    Enum.sort(rows, &sort_asc_by_amount(&1, &2))
  end

  defp sort_asc_by_amount([_,_,prev], [_,_,next]) do
    next > prev
  end

  defp print(rows) do
    IO.puts "\nTransactions:"
    Enum.each(rows, &print_to_console(&1))
  end

  defp print_to_console([date, description, amount]) do
    IO.puts "#{date} #{description} #{:erlang.float_to_binary(amount, decimals: 2)}$"
  end

end
