defmodule VenbaAnalyzer do
  require YaappuAnalyzer

  def is_venba(pa) do
    lines = String.split(pa, "\n")
    line_count = Enum.count(lines)

    last_line_word_count =
      Enum.at(lines, line_count - 1)
      |> String.split(" ")
      |> Enum.count()

    if line_count > 1 && line_count <= 12 && last_line_word_count == 3 do
      thalais = YaappuAnalyzer.identify_thalai(pa)
      Enum.all?(thalais, fn x -> String.contains?(x, "வெண்டளை") end)
    else
      false
    end
  end
end
