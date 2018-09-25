defmodule Hangman.Game do

  defmodule State do
    defstruct(
      game_state:   :initializing,  # :won | :lost | :already_used | :good_guess | :bad_guess | :initializing
      turns_left:   7,              # the number of turns left (game starts with 7)
      letters:      [],             # a list of single character strings
      used:         [],             # A sorted list of the letters already guessed
      last_guess:   ""              # the last letter guessed by the player
    )
  end

  #API FUnctions
  def new_game() do

  end

  def tally(game)do

  end
  
  def make_move(game, guess)

  end

  ##Internal Logic

end