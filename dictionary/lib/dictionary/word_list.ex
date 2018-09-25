defmodule Dictionary.WordList do

  def random_word() do
    word_list()
    |> Enum.random()
  end
  
  def word_list do
    "../../assets/words.txt"
    |> Path.expand(__DIR__)
    |> File.read!()
    |> String.split(~r/\r\n|\n/)
  end
end
