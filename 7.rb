CARD_STRENGTH = "AKQJT98765432".chars

class Hand
  attr_reader :cards, :bid

  def initialize(cards, bid)
    @cards = cards.chars
    @bid = bid.to_i

    raise "bad hand" unless @cards.size == 5
  end

  def major_rank
    tv = cards.tally.values.sort.reverse
    if tv == [5]
      0 # five of a kind
    elsif tv == [4, 1]
      1 # four of a kind
    elsif tv == [3, 2]
      2 # full house
    elsif tv[0] == 3
      3 # three of a kind
    elsif tv == [2, 2, 1]
      4 # two pair
    elsif tv == [2, 1, 1, 1]
      5 # one pair
    else
      6 # high card
    end
  end

  def minor_rank
    cards.map { '%X' % CARD_STRENGTH.index(_1) }.join
  end

  def rank_index
    "#{major_rank}#{minor_rank}"
  end
end

hands = ARGF.readlines.map { |line| Hand.new(*line.split) }

hands.sort_by!{_1.rank_index}

score = 0
rank = hands.size
hands.each do |hand|
  score += rank * hand.bid
  rank -= 1
end
puts score