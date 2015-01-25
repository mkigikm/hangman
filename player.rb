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

class HumanReferee
  def initialize(display)
    @display = display
  end

  def choose_secret
    @display.get_secret_length
  end

  def check_guess(guess)
    @display.check_guess(guess)
  end

  def tell_secret
  end
end

module ComputerHelperMethods
  def load_dict(filename)
    dict = File.readlines(filename).map(&:chomp)
  end
end

class ComputerGuesser
  include ComputerHelperMethods

  def initialize(filename)
    @dict = load_dict(filename)
  end

  def tell_secret_length(secret_length)
    @candidates = @dict.select { |word| word.length == secret_length }
    @prev_guess = ""
  end

  def take_guess(board)
    puts "#{@candidates.count} words left"
    if board.include?(@prev_guess)
      filter_match(board)
    elsif @prev_guess != ""
      filter_miss
    end

    puts "#{@candidates.count} words left"
    freq = count_frequencies(board).sort { |x, y| y.last <=> x.last }
    @prev_guess = freq.first.first
  end

  def filter_miss
    @candidates.delete_if { |word| word.include?(@prev_guess) }
  end

  def filter_match(board)
    board_regex = Regexp.new(board.map { |c| c.nil? ? "." : c }.join(""))
    @candidates.select! { |word| board_regex =~ word }
  end

  def count_frequencies(board)
    Hash.new(0).tap do |freq_hash|
      @candidates.each do |word|
        ('a'..'z').each do |c|
          freq_hash[c] += 1 if word.include?(c) && !board.include?(c)
        end
      end
    end.to_a
  end

  def win
  end

  def loss(secret)
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
