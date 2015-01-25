#!/usr/bin/env ruby

require 'dispel'

module HangmanDisplay
  attr_accessor :game

  def board_str(board)
    board.map { |c| c.nil? ? '_' : c }.join(' ')
  end

  def history_str(history)
    history_str = ('a'..'z').to_a.map do |c|
      history.include?(c) ? ' ' : c
    end
    history_str = [history_str[0..7].join, history_str[8..15].join,
    history_str[16..-1].join].join("\n")
  end
end

class HangmanDispelDisplay
  include HangmanDisplay

  def welcome
    Dispel::Screen.open do |screen|
      screen.draw "Welcome to Hangman! Press enter to begin"

      Dispel::Keyboard.output do |key|
        break if key == :enter
      end
    end
  end

  def begin_turn(board, misses, guess_history)
    Dispel::Screen.open do |screen|
      screen.draw(["Missed #{misses}", guess_history,
                    board_str(board)]).join("\n")
    end
  end

  def win(board, misses, guess_history)
  end

  def loss(board, misses, guess_history)
  end
end

class HangmanScrollingDisplay
  include HangmanDisplay

  def welcome
    puts "Welcome to Hangman!"
  end

  def display_guessing_turn
    puts "Missed #{@game.misses} so far"
    puts board_str(@game.board)
    puts history_str(@game.guess_history)
  end

  def display_win
    puts "You Win!"
  end

  def display_loss
    puts "You Lose!"
  end

  def play(game)
    @game = game

    @game.get_secret

    until @game.game_over?
      display_guessing_turn
      @game.take_turn
    end
    if @game.win?
      display_win
    else
      display_loss
    end
  end

  def get_guess_input
    guess = ""
    until ('a'..'z').include?(guess)
      puts "Choose a letter: "
      guess = gets.chomp[0].downcase
    end
    guess
  end
end

class HumanPlayer
  def initialize(display)
    @display = display
  end

  def tell_secret_length(secret_length)
  end

  def take_guess(board)
    @display.get_guess_input
  end
end

class ComputerPlayer
  def initialize
    @dict = ["apple", "boot", "triple"]
  end

  def choose_secret
    @secret = @dict.sample
    @secret.length
  end

  def check_guess(guess)
    [].tap do |correct|
      @secret.each_char.with_index do |c, i|
        correct << i if c == guess
      end
    end
  end
end

class HangmanGame
  MAX_MISSES = 8

  attr_reader :board, :misses, :guess_history

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
    @board = [nil] * length
    @guess_history = []
    @misses = 0
  end

  def take_turn
    guess = @guesser.take_guess(@board)
    @guess_history << guess

    guess_result = @referee.check_guess(guess)
    @misses += 1 if guess_result.empty?
    guess_result.each { |i| @board[i] = guess }
  end
end

if __FILE__ == $PROGRAM_NAME
  display = HangmanScrollingDisplay.new
  ref = ComputerPlayer.new
  guesser = HumanPlayer.new(display)
  game = HangmanGame.new(ref, guesser)

  display.play(game)
end
