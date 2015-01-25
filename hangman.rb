class HangmanDisplay
  def welcome
    puts "Welcome to Hangman!"
  end

  def begin_turn(board, misses, guess_history)
    board_str = board.map { |c| c.nil? ? '_' : c }.join(' ')
    history_str = ('a'..'z').to_a.map do |c|
      guess_history.include?(c) ? ' ' : c
    end
    history_str = [history_str[0..7].join, history_str[8..15].join,
      history_str[16..-1].join].join('\n')
    puts "Missed #{misses} so far"
    puts history_str
    puts board_str
  end

  def win(board, misses, guess_history)
    puts "You Win!"
  end

  def loss(board, misses, guess_history)
    puts "You Lose!"
  end
end

class HumanPlayer
  def tell_secret_length(secret_length)
    puts "The secret is #{secret_length} letters long."
  end

  def take_guess(board)
    guess = ""
    until ('a'..'z').include?(guess)
      puts "Choose a letter: "
      guess = gets.chomp[0].downcase
    end
    return guess
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

  attr_reader :board

  def initialize(referee, guesser, display)
    @referee = referee
    @guesser = guesser
    @display = display
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

  def take_turn
    @display.begin_turn(@board, @misses, @guess_history)

    guess = @guesser.take_guess(@board)
    @guess_history << guess

    guess_result = @referee.check_guess(guess)
    @misses += 1 if guess_result.empty?
    guess_result.each { |i| @board[i] = guess }
  end

  def play_game
    @misses = 0
    @guess_history = []

    @display.welcome

    secret_length = @referee.choose_secret
    @guesser.tell_secret_length(secret_length)
    @board = [nil] * secret_length

    until game_over?
      take_turn
    end

    if win?
      @display.win(@board, @misses, @guess_history)
    else
      @display.loss(@board, @misses, @guess_history)
    end
  end
end
