# Hoard (Treasure - $6) - 2 Cash. / While this is in play, when you buy a Victory card, gain a Gold.

class Prosperity::Hoard < Card
  treasure :cash => 2
  costs 6
  card_text "Treasure (cost: 6) - 2 Cash. / While this is in play, when you buy a Victory card, gain a Gold."

  def self.witness_buy(params)
    ply = params[:buyer]
    pile = params[:pile]
    parent_act = params[:parent_act]

    num_hoards = ply.cards.in_play.of_type(self.to_s).length
    return if num_hoards < 1

    if pile.card_class.is_victory?
      game = ply.game

      # Player bought a victory with at least one Hoard in play. Give the player that many Golds
      gold_pile = game.piles.find_by_card_type("BasicCards::Gold")

      game.histories.create!(:event => "#{ply.name} gained #{num_hoards} Gold#{'s' if num_hoards > 1} from #{readable_name}.",
                            :css_class => "player#{ply.seat} card_gain")

      num_hoards.times do |ix|
        ply.gain(parent_act, :pile => gold_pile)
      end
    end
  end
end