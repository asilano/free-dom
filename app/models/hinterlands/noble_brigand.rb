class Hinterlands::NobleBrigand < Card
  action :attack => true
  costs 4
  card_text "Action (Attack; cost: 4) - +1 Cash / When you buy this or play it, each other player reveals the " +
            " top 2 cards of his deck, trashes a revealed Silver or Gold you choose, and discards the rest. " +
            "If he didn't reveal a Treasure, he gains a Copper. You gain the trashed cards."

  def play(parent_act)
    super

    # Grant the cash
    player.add_cash(1)

    # Kick off the attack
    attack(parent_act)
  end

  # Notice a buy event. If it's Farmland itself, queue up the trash/upgrade action
  def self.witness_buy(params)
    ply = params[:buyer]
    pile = params[:pile]
    parent_act = params[:parent_act]
    game = ply.game

    # Check whether the card bought is Noble Brigand, and if so launch the attack
    if pile.card_class == self
      noble_brigand = pile.cards.first

      # In order to successfully attack, the attacker needs to own the attacking card
      noble_brigand.attack(parent_act, :attacker_id => ply.id, :prevent_react => true)
    end

    # The attack does not affect the buy of Noble Brigand itself in any way.
    return false
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, reveal the top two cards, and
    # do stuff based on what they are
    target = Player.find(params[:target])
    source = Player.find(params[:source])
    parent_act = params[:parent_act]

    names = target.reveal_from_deck(2)

    if names.select {|n| ["Silver", "Gold"].include?(n)}.uniq.length == 2
      # Revealed both a Silver and a Gold.
      if source.settings.autobrigand
        # Autobrigand on - Steal the Gold
        return resolve_steal(source,
                      {:target => target.id, :card_index => names.index("Gold")},
                      parent_act)
      else
        # Ask which to trash
        parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_steal;target=#{target.id}",
                                    :text => "Choose a card to steal from #{target.name}",
                                    :player => source,
                                    :game => game)
        return "OK"
      end
    elsif names.include?("Silver") || names.include?("Gold")
      # Revealed exactly one out of Silver and Gold (possibly two of the same type)
      # Call resolve_steal directly with the card's index.
      return resolve_steal(source,
                           {:target => target.id, :card_index => names.index {|n| n.in?(["Silver", "Gold"])}},
                           parent_act)
    else
      # No card to steal. Log that.
      game.histories.create!(:event => "#{source.name} stole neither of #{target.name}'s cards.",
                             :css_class => "player#{source.seat} player#{target.seat}")

      # Check if any treasures were revealed
      if target.cards.revealed.none? {|c| c.is_treasure?}
        # No treasures. Target needs to gain a Copper (after discarding)
        target.gain(parent_act, :pile => game.piles.find_by_card_type("BasicCards::Copper"))
      end

      # And discard the remaining cards
      discardrest(:target => target.id)
    end
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)

    case substep
    when "steal"
      # This is the attacker deciding what to do with the revealed cards from
      # one target
      target = Player.find(params[:target])
      controls[:revealed] += [{:player_id => target.id,
                               :type => :button,
                               :action => :resolve,
                               :text => "Steal",
                               :nil_action => nil,
                               :params => {:card => "#{self.class}#{id}",
                                           :substep => "steal",
                                           :target => target.id},
                               :cards => target.cards.revealed.map do |card|
                                  card.class.in?([BasicCards::Silver, BasicCards::Gold])
                               end
                              }]
    end
  end

  def resolve_steal(ply, params, parent_act)
    # This is at the scope of the attacker, and represents their choice of which
    # of the attackee's cards (which must contain a Silver and/or a Gold) to steal.
    # We expect to have been passed a :card_index
    if !params.include? :card_index
      return "Invalid parameters"
    end

    target = Player.find(params[:target])

    card_index = params[:card_index].to_i

    if card_index > target.cards.revealed.length
      # Asked to steal an invalid card
      return "Invalid request - card index #{card_index} is greater than number of revealed cards"
    end

    # Everything checks out. Queue up to discard the other card, and steal the specified card.
    card = target.cards.revealed[card_index]
    game.histories.create!(:event => "#{ply.name} stole #{target.name}'s #{card}.",
                           :css_class => "player#{ply.seat} player#{target.seat} card_trash")
    parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discardrest;target=#{target.id}",
                                             :game => game)
    ply.gain(parent_act, :card => card)

    return "OK"
  end

  def discardrest(params)
    # Discard the remaining cards.
    target = Player.find(params[:target])
    target.cards.revealed.each do |c|
      c.discard
    end
    game.histories.create!(:event => "#{target.name} discarded the remaining revealed cards.",
                          :css_class => "player#{target.seat} card_discard")

    return "OK"
  end
end