# AlexChurchill: [16:12] and you can actually play 5p with the cards for 4p (thus with one set)
# AlexChurchill: [16:11] That's the reason for the official restriction, yes
# ChrisHowlett: [16:11] Presumably the non-5 or 6 restriction is due to a lack of cards rather than anything else?
# AlexChurchill: [16:07] ("Green cards" means Duchy, Province, and any Victory kingdom cards such as Garden, Island, Nobles)
# AlexChurchill: [16:03] Curses are 10 x (numplayers - 1) - i.e. enough for precisely 10 undefended Witch activations
# AlexChurchill: [16:03] (and I think 15 for 5p; can't remember for 6p)
# AlexChurchill: [16:03] Estates are unlimited, other green cards have 8 for 2p and 12 for 3-4p
# AlexChurchill: [16:02] Only stacks which vary in size are Curse and green cards
# AlexChurchill: [16:02] With another set, 5 or 6, but it's better with 2-4
# AlexChurchill: [16:02] Base game, 2-4 players
# ChrisHowlett: [15:57] Dominion. What are the allowable number of players? How many cards are in each stack for each number of players?

class Pile < ActiveRecord::Base
  include GamesHelper
  
  belongs_to :game
  has_many :cards, :conditions => "location = 'pile'",
                   :dependent => :delete_all
                   
  serialize :state, Hash                 
                   
  validates_uniqueness_of :card_type, :scope => "game_id", :message => "of Kingdom cards must be different"     

  before_create :init_state
                   
  def populate(num_players)
    # Create the appropriate number of Card objects for the given type and
    # number of players in the game. 
    # 
    # If a card-type reports -1, it's unlimited - start with 10.
    start_size = card_class.starting_size(num_players)
    start_size = 10 if start_size == :unlimited
    1.upto(start_size) do |ix|
      card_params = {"game_id" => game.id,
                     "pile_id" => id,                 
                     "location" => 'pile',
                     "position" => 0}
      card_class.create!(card_params)
    end
  end      
  
  def cost
    # Return the purchase cost of the cards in this pile.
    # Do so by calling through to the instance method of any card of the type
    # this pile is for (which lets Bridges be applied).
    #
    # If there are no instances (before the start of the game, say), call the
    # class method.
    card = card_class.find_by_game_id(game)
    card ? card.cost : card_class.cost
  end
  
  def empty?
    cards(true).count == 0
  end
  
  def card_class
    to_class(card_type)
  end
  
  # Pile state notionally contains whether a pile is Contraband this turn; but that's actually stored on the Game object
  # because we wipe that clean each turn. Synthesise it onto the pile.
  def state
    ret = self[:state] || {}
    if game.facts[:contraband] && game.facts[:contraband].include?(card_type)
      ret[:contraband] = true
    end
    return ret
  end
  
  def state=(value)
    self[:state] = value.reject{|k,v| k == :contraband}
  end

private

  def init_state
    self.state ||= Hash.new(0)
  end
  
end
