defmodule YaappuAnalyzer do
  require TamilCharacters
  alias TamilCharacters, as: TC

  @kuril [
    TC.v_a(),
    TC.v_i(),
    TC.v_u(),
    TC.v_e(),
    TC.v_o(),
    TC.ka(),
    TC.nga(),
    TC.sa(),
    TC.nja(),
    TC.da(),
    TC.nnna(),
    TC.ta(),
    TC.nna(),
    TC.pa(),
    TC.ma(),
    TC.ya(),
    TC.ra(),
    TC.la(),
    TC.va(),
    TC.lla(),
    TC.za(),
    TC.rra(),
    TC.na(),
    TC.i(),
    TC.u(),
    TC.e(),
    TC.o(),
    TC.o1()
  ]

  @nedil [
    TC.v_aa(),
    TC.v_ii(),
    TC.v_uu(),
    TC.v_ai(),
    TC.v_oo(),
    TC.v_au(),
    TC.thunaikaal(),
    TC.ii(),
    TC.uu(),
    TC.ee(),
    TC.ai(),
    TC.oo(),
    TC.au(),
    TC.oo1(),
    TC.au1()
  ]

  @nirai ~r{kko*|kno*|kk|kn}
  @ner ~r{ko*|no*|k|n}

  def is_kuril(s) do
    String.contains?(s, @kuril)
  end

  def is_nedil(s) do
    String.contains?(s, @nedil)
  end

  def is_otru(s) do
    String.contains?(s, TC.pulli())
  end

  def maathirai_encoding(s) do
    cond do
      is_otru(s) -> "o"
      is_nedil(s) -> "n"
      is_kuril(s) -> "k"
      true -> "*"
    end
  end

  def asai_encoding(s) do
    nirai_encoded = Regex.replace(@nirai, s, "N")
    Regex.replace(@ner, nirai_encoded, "n")
  end

  def seer_encoding(s) do
    cond do
      "n" == s -> "நாள்"
      "N" == s -> "மலர்"
      "nn" == s -> "தேமா"
      "Nn" == s -> "புளிமா"
      "NN" == s -> "கருவிளம்"
      "nN" == s -> "கூவிளம்"
      "nnn" == s -> "தேமாங்காய்"
      "nnN" == s -> "தேமாங்கனி"
      "Nnn" == s -> "புளிமாங்காய்"
      "NnN" == s -> "புளிமாங்கனி"
      "NNn" == s -> "கருவிளங்காய்"
      "NNN" == s -> "கருவிளங்கனி"
      "nNn" == s -> "கூவிளங்காய்"
      "nNN" == s -> "கூவிளங்கனி"
      "nnnn" == s -> "தேமாந்தண்பூ"
      "nnnN" == s -> "தேமாந்தண்ணிழல்"
      "nnNn" == s -> "தேமாநறும்பூ"
      "nnNN" == s -> "தேமாநறுநிழல்"
      "Nnnn" == s -> "புளிமாந்தண்பூ"
      "NnnN" == s -> "புளிமாந்தண்ணிழல்"
      "NnNn" == s -> "புளிமாநறும்பூ"
      "NnNN" == s -> "புளிமாநறுநிழல்"
      "nNnn" == s -> "கூவிளந்தண்பூ"
      "nNnN" == s -> "கூவிளந்தண்ணிழல்"
      "nNNn" == s -> "கூவிளநறும்பூ"
      "nNNN" == s -> "கூவிளநறுநிழல்"
      "NNnn" == s -> "கருவிளந்தண்பூ"
      "NNnN" == s -> "கருவிளந்தண்ணிழல்"
      "NNNn" == s -> "கருவிளநறும்பூ"
      "NNNN" == s -> "கருவிளநறுநிழல்"
      true -> "nothing"
    end
  end

  def identify_seer(s) do
    lines = String.split(s, "\n")

    for line <- lines do
      for word <- String.split(line, " ") do
        apply_ai_au_kaarakkurukkam(word)
        |> Enum.map(&maathirai_encoding/1)
        |> Enum.join()
        |> asai_encoding
        |> seer_encoding
      end
    end
  end

  def apply_ai_au_kaarakkurukkam(s) do
    [head | tail] = String.graphemes(s)
    [head | for(x <- tail, do: String.replace(x, ~r{#{TC.ai()}|#{TC.au()}}, ""))]
  end

  def thalai_encoding(nilaiseer, varunjseer) do
    cond do
      String.length(nilaiseer) == 2 ->
        cond do
          String.last(nilaiseer) == String.first(varunjseer) -> "ஆசிரியத்தளை"
          String.last(nilaiseer) != String.first(varunjseer) -> "இயற்சீர் வெண்டளை"
          true -> "தளை தட்டுகிறது"
        end

      String.length(nilaiseer) == 3 ->
        cond do
          String.last(nilaiseer) == String.first(varunjseer) && String.first(varunjseer) == "n" ->
            "வெண்சீர் வெண்டளை"

          String.last(nilaiseer) == "n" && String.first(varunjseer) == "N" ->
            "கலித்தளை"

          String.last(nilaiseer) == String.first(varunjseer) && String.first(varunjseer) == "N" ->
            "ஒன்றிய வஞ்சித்தளை"

          String.last(nilaiseer) == "N" && String.first(varunjseer) == "n" ->
            "ஒன்றாத வஞ்சித்தளை"

          true ->
            "தளை தட்டுகிறது"
        end

      true ->
        "தளை தட்டுகிறது"
    end
  end

  def identify_thalai(s) do
    words =
      String.replace(s, "\n", " ")
      |> String.split(" ")

    asai_pairs =
      for word <- words do
        apply_ai_au_kaarakkurukkam(word)
        |> Enum.map(&maathirai_encoding/1)
        |> Enum.join()
        |> asai_encoding
      end
      |> Enum.chunk_every(2, 1)

    for asai_pair <- Enum.filter(asai_pairs, fn y -> Enum.count(y) > 1 end) do
      thalai_encoding(Enum.at(asai_pair, 0), Enum.at(asai_pair, 1))
    end
  end

  def identify_line_type(s) do
    for l <- String.split(s, "\n") do
      case Enum.count(String.split(l, " ")) do
        1 -> "தனிச்சொல்"
        2 -> "குறளடி"
        3 -> "சிந்தடி"
        4 -> "அளவடி"
        5 -> "நெடிலடி"
        6 -> "அறுசீர் கழிநெடிலடி"
        7 -> "எழுசீர் கழிநெடிலடி"
        8 -> "எண்சீர் கழிநெடிலடி"
        _ -> "கழிநெடிலடி"
      end
    end
  end
end
