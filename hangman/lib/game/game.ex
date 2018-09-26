defmodule Hangman.Game do
  @num_turns 7
  defmodule State do

    #we don't need all this other gobbledygook
    #keeping num turns left in state? Forgetaboutit
    #we can derive that from guesses
    defstruct(
      game_state: :initializing,  # :won | :lost | :already_used | :good_guess | :bad_guess | :initializing | 
                                  # developer added :processing for internal Hangman.Game state only
      word:       [],             # 'secret' word, only set during new_game
      guesses:    []              # holds all user input (goog or bad guess) except for duplicates, in reverse order
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
      turns_left: @num_turns - length(used),
      letters:    full_word_helper(game.game_state, game.word, get_letters(game)),
      used:       Enum.sort(used),
      last_guess: List.first(game.guesses) #always most recent (even if input is already used, see )
    }
  end

  def make_move(game = %Hangman.Game.State{}, guess) do
    updated_game = game
      |> add_guess(guess)
      |> update_state()
    {updated_game, tally(updated_game)}
  end

  ########## Internal Logic ##########

  # gets guesses that were "good guesses", with '_' representing un-guessed characters 
  defp get_letters(game = %Hangman.Game.State{}) do
    game.word 
      |> Enum.map(&letter_guard(Enum.member?(game.guesses, &1), &1))
  end

  defp letter_guard(true, char), do: char
  defp letter_guard(false, _),   do: "_"
  
  # gets guesses that were "bad guesses"
  defp get_used(game = %Hangman.Game.State{}) do
    game.guesses 
      |> Enum.filter(&!Enum.member?(game.word, &1))
  end

  #used to show the entire word in the tally if the game is :lost
  #if the game is :won, all the underscores are already gone
  defp full_word_helper(:lost, full_word, _hidden_letters), do: full_word
  defp full_word_helper(_, _full_word, hidden_letters), do: hidden_letters

  # infer_state(won, turns_left, good_guess?)
  defp infer_state(true , _, _), do: :won
  defp infer_state(false, 0, _), do: :lost
  defp infer_state(false, _, true), do: :good_guess
  defp infer_state(false, _, false), do: :bad_guess

  # if guess is a duplicate, game_state == :already_used allows it to bypass update_state logic
  defp add_guess(game, guess) do
    dup_guess(Enum.member?(game.guesses, guess), game, guess)
  end

  defp dup_guess(true, game, guess) do
    %Hangman.Game.State{ game |
      game_state: :already_used,
      guesses: reorg_guesses(game.guesses, guess)
    }
  end

  defp dup_guess(false, game, guess) do
    %Hangman.Game.State{ game |
      game_state: :processing, # :processing will always be gone by the time the state or tally are returned to the caller
      guesses: [guess | game.guesses]
    }
  end

  # If a guess is a duplicate, make sure it shows up as the "last guess"
  # TODO: If I ever end up using the extra functionality i'm adding by logging all the guesses, 
  #       I will then generate a Set from the guesses to make things more efficient.
  #       Maybe it would have just been good practice to do that now?
  defp reorg_guesses(word, guess) do
    new_word = word |> List.delete(guess)
    [guess | new_word]
  end

  # Infer the new state of the game if we arent dealing with a duplicate guess
  # Tally takes care of everything else
  defp update_state(game = %Hangman.Game.State{game_state: :already_used}), do: game
  defp update_state(game = %Hangman.Game.State{}) do
    won = won?(game)
    turns_left = @num_turns - length(get_used(game))
    good_guess = good_guess?(game)

    %Hangman.Game.State{ game |
      game_state: infer_state(won, turns_left, good_guess)
    }
  end

  # Game is :won if there are no underscores
  defp won?(game = %Hangman.Game.State{}) do
    get_letters(game)
      |> Enum.member?("_")
      |> Kernel.not
  end

  #Current guess is good if it's a member of the secret word
  defp good_guess?(game) do
    Enum.member?(game.word, List.first(game.guesses))
  end
end
