defmodule Hangman.Game do

  defmodule State do
    defstruct(
      game_state:   :initializing,  # :won | :lost | :already_used | :good_guess | :bad_guess | :initializing
      turns_left:   7,
      word:         [],      
      guesses:      []
    )
  end

  ########## API Functions ##########
  
  def new_game() do
    %Hangman.Game.State{word: Dictionary.random_word() |> String.codepoints()}
  end

  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters:    get_letters(game),
      used:       get_used(game),
      last_guess: Enum.at(game.guesses, -1)
    }
  end
  
  def make_move(_game, _guess) do

  end

  ########## Internal Logic ##########

  def get_letters(game) do
    game.word 
    |> Enum.map(&letter_guard(Enum.member?(game.guesses, &1), &1))
  end

  def letter_guard(true, char), do: char
  def letter_guard(false, _),   do: "_"
  
  def get_used(game) do
    game.guesses 
    |> Enum.filter(&!Enum.member?(game.word, &1))
  end

  def won?(game) do
    get_letters(game)
    |> Enum.member?("_")
    |> Kernel.not
  end

end