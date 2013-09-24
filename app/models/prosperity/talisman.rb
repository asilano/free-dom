# Talisman (Treasure - $4) - 1 Cash. While this is in play, when you buy a card costing 4 or less that is not a Victory card, gain a copy of it.

class Prosperity::Talisman < Card
  treasure :cash => 1
  costs 4
  card_text "Treasure (cost: 4) - 1 Cash. While this is in play, when you buy a card costing 4 or less that is not a Victory card, gain a copy of it."

  def self.witness_buy(params)
    ply = params[:buyer]
    pile = params[:pile]
    parent_act = params[:parent_act]

    # Exit if the pile doesn't meet requirements
    return if pile.card_class.is_victory? || pile.cost > 4

    num_talismans = ply.cards.in_play.of_type(self.to_s).length
    return if num_talismans < 1

    game = ply.game

    # Player bought a non-Victory with at least one Talisman in play. Give the player that many copies of the card
    game.histories.create!(:event => "#{ply.name} gained #{num_talismans} cop#{num_talismans > 1 ? 'ies' : 'y'} of #{pile.card_class.readable_name} from #{readable_name}.",
                           :css_class => "player#{ply.seat} card_gain")

    num_talismans.times do |ix|
      parent_act = ply.gain(parent_act, :pile => pile)
    end

    return parent_act
  end
end