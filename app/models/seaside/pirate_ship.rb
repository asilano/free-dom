# 15  Pirate Ship  Seaside  Action - Attack  $4  Choose one: Each other player reveals the top 2 cards of his deck, trashes a revealed Treasure that you choose, discards the rest, and if anyone trashed a Treasure you take a Coin token; or, +1 Coin per Coin token you've taken with Pirate Ships this game.

class Seaside::PirateShip < Card
  costs 4
  action :attack => true
  card_text "Action (Attack; cost: 4) - Choose one: Each other player reveals the top 2 cards of his deck, trashes a revealed Treasure that you choose, discards the rest, and if anyone trashed a Treasure you take a Coin token; or +1 Cash per Coin token you've taken with Pirate Ships this game."

  def play(parent_act)
    super

    # Like Minion, Pirate Ship is an attack regardless of which mode it's in. However, since
    # Reacting is just Something You Can Do, rather than a "triggered ability",
    # we should find which mode we're in before we ask for reactions.
    parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_mode",
                               :text => "Choose Pirate Ship mode",
                               :player => player,
                               :game => game)
    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)
    case substep
    when "mode"
      controls[:player] += [{:type => :buttons,
                             :action => :resolve,
                             :label => "#{readable_name} mode:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "mode"},
                             :options => [{:text => "Trash treasures",
                                           :choice => "trash"},
                                          {:text => "Gain cash",
                                           :choice => "cash"}]
                            }]
    when "choose"
      # This is the attacker deciding what to do with the revealed cards from
      # one target
      target = Player.find(params[:target])
      controls[:revealed] += [{:player_id => target.id,
                               :type => :button,
                               :action => :resolve,
                               :text => "Trash",
                               :nil_action => nil,
                               :params => {:card => "#{self.class}#{id}",
                                           :substep => "choose",
                                           :target => target.id},
                               :cards => target.cards.revealed.map do |card|
                                  card.is_treasure?
                               end
                              }]
    end
  end

  def resolve_mode(ply, params, parent_act)
    # We expect to have a :choice parameter, either "cash" or "trash"
    if (not params.include? :choice) or
       (not params[:choice].in? ["cash", "trash"])
      return "Invalid parameters"
    end

    # All looks fine, process the choice
    if params[:choice] == "cash"
      # Nice Pirate Ship. Grant the cash, write the history, set up the param
      ply.cash += ply.state.pirate_coins
      ply.save!
      game.histories.create!(:event => "#{ply.name} chose to take cash from the #{readable_name}, gaining #{ply.state.pirate_coins} cash.",
                            :css_class => "player#{ply.seat}")
      attack_type = "nice"
    else
      # Nasty Pirate Ship. Write the history and set up the param
      game.histories.create!(:event => "#{ply.name} chose to trash treasures with the #{readable_name}.",
                            :css_class => "player#{ply.seat}")
      attack_type = "nasty"

      # We also need to set a Game-level action to grant the token if the act succeeded
      parent_act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_gaintoken",
                                              :game => game)
      self.state = "no"
      save!
    end

    # Create the attack framework
    attack(parent_act, :attack_type => attack_type)

    return "OK"
  end

  def attackeffect(params)
    # Golden path - the attack is a no-op in "nice" mode
    if params[:attack_type] == "nice"
      return "OK"
    end

    raise "Invalid attack type" unless params[:attack_type] == "nasty"

    # Effect of the attack succeeding - that is, reveal the top two cards of
    # the target's deck, and ask the attacker to pick a treasure.
    target = Player.find(params[:target])
    source = Player.find(params[:source])
    parent_act = params[:parent_act]

    # Get the attack target to reveal the top two cards from their deck
    target.reveal_from_deck(2)

    if target.cards.revealed.select {|c| c.is_treasure?}.map(&:class).uniq.length == 1
      # Target revealed only one type of treasure. Call into resolve_choose directly
      ix = target.cards.revealed.index {|c| c.is_treasure?}
      return resolve_choose(source, {:card_index => ix, :target => target.id}, parent_act)
    elsif !target.cards.revealed.any? {|c| c.is_treasure?}
      # Target revealed no treasures. Just log, and discard the cards
      game.histories.create!(:event => "#{source.name} trashed neither of #{target.name}'s cards, as neither was a treasure.",
                            :css_class => "player#{source.seat} player#{target.seat} card_trash")

      target.cards.revealed.each do |c|
        c.discard
      end
      game.histories.create!(:event => "#{target.name} discarded their revealed cards.",
                            :css_class => "player#{target.seat} card_discard")
    else
      # Hang an action off the parent to ask the attacker to choose a card
      # to trash.
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose;target=#{target.id}",
                                 :text => "Choose Pirate Ship actions for #{target.name}",
                                 :player => source,
                                 :game => game)
    end

    return "OK"
  end

  def resolve_choose(ply, params, parent_act)
    # We expect to have been passed either a :card_index
    if !params.include? :card_index
      return "Invalid parameters"
    end

    target = Player.find(params[:target])

    card_index = params[:card_index].to_i

    if card_index > 1
      # Asked to trash/take an invalid card
      return "Invalid request - card index #{card_index} is greater than number of revealed cards"
    end

    # Everything checks out. Trash the specified card.
    card = target.cards.revealed[card_index]
    card.trash
    game.histories.create!(:event => "#{ply.name} chose to trash #{target.name}'s #{card.class.readable_name}.",
                          :css_class => "player#{ply.seat} player#{target.seat} card_trash")

    # Mark this card's state to say we managed to trash a treasure
    self.state = "yes"
    save!

    # Discard the remaining cards.
    target.cards.revealed(true).each do |c|
      target.cards.in_discard << c
      c.discard
    end
    game.histories.create!(:event => "#{target.name} discarded the remaining revealed cards.",
                          :css_class => "player#{target.seat} card_discard")

    return "OK"
  end

  def gaintoken(params)
    # Grant the card owner a pirate-ship token if they managed to trash a treasure
    if self.state == "no"
      # No treasures trashed.
      game.histories.create!(:event => "#{player.name} trashed no treasures, so doesn't gain a token.",
                            :css_class => "player#{player.seat}")
    else
      # Treasures trashed! Gain a token.
      player.state.pirate_coins += 1
      player.state.save!
      game.histories.create!(:event => "#{player.name} trashed at least one treasure, so gains a token (to #{player.state.pirate_coins}).",
                            :css_class => "player#{player.seat}")
    end
  end

end

