class HangmanDisplay
end

class HumanPlayer
end

class ComputerPlayer
end

class HangmanGame
  MAX_MISSES = 8

  attr_reader :board

  def initialize(referee, guesser, display)
    @referee = referee
    @guesser = guesser
    @display = display
  end

  def play_game
    misses = 0
    guess_history = []

    @display.welcome

    secret_length = @referee.choose_secret
    @guesser.tell_secret_length(secret_length)
    board = [nil] * secret_length

    while misses < MAX_MISSES
      @display.begin_turn(board, misses, guess_history)

      guess = @guesser.take_guess(board)
      guess_history << guess

      guess_result = @referee.check_guess(guess)
      misses += 1 if guess_result.empty?
      guess_result.each { |i| board[i] = guess }
    end
  end
end
