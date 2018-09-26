defmodule Hangman.Game do

  defmodule State do
    defstruct(
      game_state:   :initializing,  # :won | :lost | :already_used | :good_guess | :bad_guess | :initializing
      word:         [],      
      guesses:      []
    )
  end

  ########## API Functions ##########

  def new_game() do
    %Hangman.Game.State{word: Dictionary.random_word() |> String.codepoints()}
  end

  def tally(game = %Hangman.Game.State{}) do
    used = get_used(game)
    %{
      game_state: game.game_state,
      turns_left: 7 - length(used),
      letters:    get_letters(game),
      used:       Enum.sort(used),
      last_guess: List.first(game.guesses)
    }
  end
  
  def make_move(game = %Hangman.Game.State{}, guess) do
    updated_game = game
      |> add_guess(guess)
      |> update_state()
    {updated_game, tally(updated_game)}
  end

  ########## Internal Logic ##########

  def get_letters(game = %Hangman.Game.State{}) do
    game.word 
      |> Enum.map(&letter_guard(Enum.member?(game.guesses, &1), &1))
  end

  def letter_guard(true, char), do: char
  def letter_guard(false, _),   do: "_"
  
  def get_used(game = %Hangman.Game.State{}) do
    game.guesses 
      |> Enum.filter(&!Enum.member?(game.word, &1))
  end

  #   infer_state(won, turns_left, good_guess?)
  def infer_state(true , _, _), do: :won
  def infer_state(false, 0, _), do: :lost
  def infer_state(false, _, true), do: :good_guess
  def infer_state(false, _, false), do: :bad_guess

  def add_guess(game, guess) do
    dup_guess(Enum.member?(game.guesses, guess), game, guess)
  end

  def dup_guess(true, game, guess) do
    %Hangman.Game.State{ game |
      game_state: :already_used,
      guesses: move_guess_to_beginning(game.guesses, guess)
    }
  end

  def dup_guess(false, game, guess) do
    %Hangman.Game.State{ game |
      game_state: :processing,
      guesses: [guess | game.guesses]
    }
  end

  def move_guess_to_beginning(word, guess) do
    new_word = word |> List.delete(guess)
    [guess | new_word]
  end

  def update_state(game = %Hangman.Game.State{game_state: :already_used}) do
    game
  end

  def update_state(game = %Hangman.Game.State{}) do
    won = won?(game)
    turns_left = 7 - Enum.count(game.guesses)
    good_guess = good_guess?(game)

    %Hangman.Game.State{ game |
      game_state: infer_state(won, turns_left, good_guess)
    }
  end

  def won?(game = %Hangman.Game.State{}) do
    get_letters(game)
      |> Enum.member?("_")
      |> Kernel.not
  end

  def good_guess?(game) do
    Enum.member?(game.word, List.first(game.guesses))
  end
end