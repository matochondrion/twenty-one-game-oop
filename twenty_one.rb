module Hand
  attr_reader :cards

  def display_flop
    puts
    puts "========== #{name}'s Cards =========="
    puts cards[0]
    puts "??"
  end

  def display_hand
    puts
    puts "========== #{name}'s Cards =========="
    puts cards
  end

  def busted?
    total > 21
  end

  def total
    total = 0

    @cards.each do |card|
      if card.ace?
        total += 11
      elsif card.jack? || card.queen? || card.king?
        total += 10
      else
        total += card.face.to_i
      end
    end

    # correct for Aces
    @cards.select(&:ace?).size.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def hit(deck)
    cards << deck.deal_one_card
  end

end

class Participant
  include Hand

  attr_accessor :name, :cards

  def initialize
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
    @cards = []
  end

  def << (card)
    @cards << card
  end
end

class Player < Participant

  def choose_name
    loop do
      puts
      puts "what is your name?"
      self.name = gets.chomp.strip
      break unless self.name == ''
      puts "Sorry, that's an invalid name."
    end
  end

  def display_total
    puts "total: #{total}"
  end
end

class Dealer < Participant
  NAMES = ['Number 5', 'Chappie', 'Sonny', 'HAL']

  def choose_name
    self.name = NAMES.sample
  end

  def display_total
    puts "total: #{total}"
  end
end

class Card
  SUITS = %w(H C D S)
  FACES = %w(2 3 4 5 6 7 8 9 10 J Q K A)

  attr_reader :suit, :name, :face, :value
  def initialize(suit, face)
    @suit = suit
    @face = face
  end

  def to_s
    "=> The #{face_name} of #{suit_name}"
  end

  def jack?
    @face == 'J'
  end

  def queen?
    @face == 'Q'
  end

  def king?
    @face == 'K'
  end

  def ace?
    @face == 'A'
  end

  private

  def suit_name
    case suit
    when 'H' then 'Hearts'
    when 'C' then 'Clubs'
    when 'D' then 'Diamonds'
    when 'S' then 'Spades'
    end
  end

  def face_name
    case face
    when 'J' then 'Jack'
    when 'Q' then 'Queen'
    when 'K' then 'King'
    when 'A' then 'Ace'
    else
      face.to_s
    end
  end
end

class Deck
  SUITS = %w(H D C S)
  FACE_CARDS = %w(J Q K)
  attr_accessor :cards

  def initialize
    # obviously, we need some data structure to keep track of cards
    # array, hash, something else?
    @cards = []
    # SUITS.each do |suit|
      # @cards << Card.new(suit, 'A', 11)
      # @cards += (2..10).map { |i| Card.new(suit, i.to_s, i) }
      # @cards += FACE_CARDS.map { |f| Card.new(suit, f, 10) }
    # end

    Card::SUITS.each do |suit|
      Card::FACES.each do |face|
        @cards << Card.new(suit, face)
      end
    end

    @cards.shuffle!
  end

  def deal_one_card
    @cards.pop
  end

end

class TwentyOne
  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def play
    clear
    # puts @deck.cards
    display_welcome_message
    @player.choose_name
    @dealer.choose_name
    deal_cards
    player_turn
    clear
    @player.display_hand
    @player.display_total
    if @player.busted?
      display_winner
      return display_game_over
    end
    dealer_turn
    clear
    @player.display_hand
    @player.display_total
    @dealer.display_hand
    @dealer.display_total
    display_winner
    display_game_over
  end

  private

  def ask_player_for_move
    valid_choices = %w(hit stay h s)
    move = nil

    loop do
      puts
      puts %(Would you like to "stay" or "hit"?)
      move = gets.chomp.downcase.strip
      break unless valid_choices.none? { |valid| move == valid }
      puts "Sorry, that was an invalid choice. Please Try again."
    end

    move[0] == 'h' ? move = 'hit' : move = 'stay'
  end

  def display_welcome_message
    puts "Welcome to Twenty One!"
  end

  def deal_cards
    2.times do
      @player << @deck.deal_one_card
      @dealer << @deck.deal_one_card
    end
  end

  def display_winner
    puts

    if @player.total > 21
      puts "#{@player.name} BUSTED!"
    elsif @dealer.total > 21
      puts "Dealer BUSTED - #{@player.name} WINS!!"
    elsif @player.total > @dealer.total
      puts "#{@player.name} WINS!!"
    elsif @player.total == @dealer.total
      puts "It's a tie...noone wins."
    else
      puts "Dealer WINS!"
    end

  end

  def display_game_over
    puts
    puts "GAME OVER"
    puts
  end

  def clear
    system 'clear'
  end

  def dealer_turn
    puts
    puts "dealer's turn"
    until @dealer.total >= 17 && @dealer.total > @player.total
      @dealer.hit(@deck)
    end
  end

  def player_turn
    until @player.total >= 21
      clear
      @player.display_hand
      @player.display_total
      @dealer.display_flop
      move = ask_player_for_move
      break if move == 'stay'
      @player.hit(@deck)
    end
  end

end

TwentyOne.new.play
