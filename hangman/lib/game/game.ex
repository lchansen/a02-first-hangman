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
      letters:    full_word_helper(game.game_state, game.word, get_letters(game)),
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

  defp get_letters(game = %Hangman.Game.State{}) do
    game.word 
      |> Enum.map(&letter_guard(Enum.member?(game.guesses, &1), &1))
  end

  defp letter_guard(true, char), do: char
  defp letter_guard(false, _),   do: "_"
  
  defp get_used(game = %Hangman.Game.State{}) do
    game.guesses 
      |> Enum.filter(&!Enum.member?(game.word, &1))
  end

  defp full_word_helper(:lost, full_word, _hidden_letters), do: full_word
  defp full_word_helper(_, _full_word, hidden_letters), do: hidden_letters

  #   infer_state(won, turns_left, good_guess?)
  defp infer_state(true , _, _), do: :won
  defp infer_state(false, 0, _), do: :lost
  defp infer_state(false, _, true), do: :good_guess
  defp infer_state(false, _, false), do: :bad_guess

  defp add_guess(game, guess) do
    dup_guess(Enum.member?(game.guesses, guess), game, guess)
  end

  defp dup_guess(true, game, guess) do
    %Hangman.Game.State{ game |
      game_state: :already_used,
      guesses: move_guess_to_beginning(game.guesses, guess)
    }
  end

  defp dup_guess(false, game, guess) do
    %Hangman.Game.State{ game |
      game_state: :processing,
      guesses: [guess | game.guesses]
    }
  end

  defp move_guess_to_beginning(word, guess) do
    new_word = word |> List.delete(guess)
    [guess | new_word]
  end

  defp update_state(game = %Hangman.Game.State{game_state: :already_used}) do
    game
  end

  defp update_state(game = %Hangman.Game.State{}) do
    won = won?(game)
    turns_left = 7 - length(get_used(game))
    good_guess = good_guess?(game)

    %Hangman.Game.State{ game |
      game_state: infer_state(won, turns_left, good_guess)
    }
  end

  defp won?(game = %Hangman.Game.State{}) do
    get_letters(game)
      |> Enum.member?("_")
      |> Kernel.not
  end

  defp good_guess?(game) do
    Enum.member?(game.word, List.first(game.guesses))
  end
end