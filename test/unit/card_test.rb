require File.dirname(__FILE__) + '/../test_helper'

class CardTest < ActiveSupport::TestCase

  def setup
  	load_our_fixtures :tournaments, :cards
  end
  
  def test_number_presence
  	card = Card.find(:first)
  	card.number = nil
  	assert_not_valid(card)
  	card.number = ""
  	assert_not_valid(card)
  	assert_not_valid(Card.new)
  	assert_valid(Card.new(:number => 42))
  end
  
  def test_number_numericality
  	card = Card.find(:first)
  	card.number = "a"
  	assert_not_valid(card)
  	card.number = 1.5
  	assert_not_valid(card)
  	card.number = 42
  	assert_valid(card)
  end  

end
