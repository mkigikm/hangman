#!/usr/bin/env ruby

require './hangman_display'
require './player'

class HangmanGame
  MAX_MISSES = 8

  attr_reader :board, :misses, :history

  def initialize(referee, guesser)
    @referee = referee
    @guesser = guesser
  end

  def loss?
    @misses == MAX_MISSES
  end

  def win?
    !@board.include?(nil)
  end

  def game_over?
    win? || loss?
  end

  def get_secret
    length = @referee.choose_secret
    @guesser.tell_secret_length(length)
    @board = [nil] * length
    @history = []
    @misses = 0
  end

  def take_turn
    guess = @guesser.take_guess(@board)
    @history << guess

    guess_result = @referee.check_guess(guess)
    @misses += 1 if guess_result.empty?
    guess_result.each { |i| @board[i] = guess }
  end

  def play
    get_secret

    until game_over?
      take_turn
    end
    if win?
      @guesser.win
    else
      @guesser.loss(@referee.tell_secret)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  display = HangmanScrollingDisplay.new
  cref = ComputerReferee.new("dictionary.txt")
  href = HumanReferee.new(display)
  cguesser = ComputerGuesser.new("dictionary.txt")
  hguesser = HumanGuesser.new(display)
  game = HangmanGame.new(cref, hguesser)
  display.game = game

  game.play
end
