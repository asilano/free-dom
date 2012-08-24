class Pile < ActiveRecord::Base
  include GamesHelper
  
  belongs_to :game
  has_many :cards, :conditions => "location = 'pile'",
                   :dependent => :delete_all
                   
  serialize :state, Hash                 
                   
  validates :card_type, :uniqueness => {:scope => "game_id", :message => "of Kingdom cards must be different"}

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
