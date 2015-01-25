require 'dispel'

module HangmanDisplayHelpers
  MAN = <<EndOfMan
  ____________
 |            |
 |           _|_
 |          /   \\
 |         | x x |
 |         |  _  |
 |          \\___/
 |          \\ | /
 |           \\|/
 |            |
 |            |
 |            |
 |            |
 |           / \\
 |          /   \\
 |         /     \\
_|_________________________
EndOfMan

  MAN_INDICATORS = <<EndOfMan
  ____________
 |            1
 |           212
 |          2   2
 |         2 8 8 2
 |         2  8  2
 |          22222
 |          4 3 5
 |           435
 |            3
 |            3
 |            3
 |            3
 |           6 7
 |          6   7
 |         6     7
_|_________________________
EndOfMan

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

  def man_str(misses)
    MAN.dup.tap do |man|
      man.each_char.with_index do |c, i|
        man[i] = ' ' if  misses < MAN_INDICATORS[i].to_i
      end
    end
  end
end

class HangmanDisplay
  attr_accessor :game
end

class HangmanDispelDisplay < HangmanDisplay
  include HangmanDisplayHelpers

  def get_guess_input
    guess = ""

    Dispel::Screen.open do |screen|
      screen.draw game_board
      Dispel::Keyboard.output do |key|
        if ('a'..'z').include?(key)
          guess = key
          break
        end
      end
    end

    guess
  end

  def display_win
    display_finish("You win!")
  end

  def display_loss(secret)
    display_finish("You suck! #{secret} would have save you.")
  end

  private
  def game_board
    [
      man_str(@game.misses),
      history_str(@game.history),
      board_str(@game.board)
    ].join("\n")
  end

  def display_finish(status)
    Dispel::Screen.open do |screen|
      screen.draw [game_board, "#{status} Press (q) to quit."].join("\n")
      Dispel::Keyboard.output do |key|
        if ['q'].include?(key)
          return
        end
      end
    end
  end
end

class HangmanScrollingDisplay < HangmanDisplay
  include HangmanDisplayHelpers

  def display_board
    puts man_str(@game.misses)
    puts "Missed #{@game.misses} so far"
    puts board_str(@game.board)
    puts history_str(@game.history)
  end

  def display_win
    puts "You Win!"
  end

  def display_loss
    puts "You Lose!"
  end

  def get_guess_input
    display_board

    guess = ""
    until ('a'..'z').include?(guess)
      puts "Choose a letter: "
      guess = gets.chomp[0].downcase
    end

    guess
  end

  def get_secret_length
    puts "How long is the word you are thing of? "
    gets.to_i
  end

  def check_guess(guess)
    display_board

    puts "Where does '#{guess}' appear in you word?"
    locations = gets.chomp
    locations == "" ? [] : locations.split(",").map(&:to_i)
  end
end
