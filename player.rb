class HumanGuesser
  def initialize(display)
    @display = display
  end

  def tell_secret_length(secret_length)
  end

  def take_guess(board)
    @display.get_guess_input
  end

  def win
    @display.display_win
  end

  def loss(secret)
    @display.display_loss(secret)
  end
end

module ComputerHelperMethods
  def load_dict(filename)
    dict = File.readlines(filename).map(&:chomp)
  end
end

class ComputerReferee
  include ComputerHelperMethods

  def initialize(dict_filename)
    @dict = load_dict(dict_filename)
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

  def tell_secret
    @secret
  end
end
