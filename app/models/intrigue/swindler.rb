class Intrigue::Swindler < Card
  costs 3
  # Order becomes important if any pile has fewer cards than attacked players
  action :attack => true,
         :order_relevant => lambda{|params| game.piles.any?{|p| p.cards.size < game.players.size - 1}}
  card_text "Action (Attack; cost: 3) - +2 Cash. Each other player trashes the top " +
                               "card of his or her deck, and gains a card " +
                               "with the same cost of your choice."

  def play(parent_act)
    super

    player.add_cash(2)

    attack(parent_act)
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)
    case substep
    when "choose"
      target = Player.find(params[:target])
      controls[:piles] += [{:type => :button,
                            :action => :resolve,
                            :text => "Give to #{target.name}",
                            :nil_action => (game.piles.any?{|p| p.cost == params[:trashed_cost].to_i and not p.empty?} ? nil : "Give nothing to #{target.name}"),
                            :params => {:card => "#{self.class}#{id}",
                                        :substep => "choose",
                                        :target => target.id,
                                        :trashed_cost => params[:trashed_cost]},
                            :piles => game.piles.map do |pile|
                              pile.cost == params[:trashed_cost].to_i and not pile.empty?
                            end
                           }]
    end
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, trash the top card of the
    # target's deck, and ask the attacker to pick a card of equal value.
    target = Player.find(params[:target])
    source = Player.find(params[:source])
    parent_act = params[:parent_act]

    # Trash the top card of the target's deck. Note its cost
    target.renum(:deck)
    target.shuffle_discard_under_deck if target.cards.deck.empty?

    card = target.cards.deck[0]
    if ( card )
      cost = card.cost
      card.trash
      game.histories.create!(:event => "Swindler caused #{target.name} to trash a #{card.class.readable_name}.",
                            :css_class => "player#{target.seat} card_trash")

      # And hang an action off the parent to ask the attacker to choose a
      # replacement card.
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_choose;target=#{target.id};trashed_cost=#{cost}",
                                       :text => "Choose Swindler actions for #{target.name}")
      act.player = source
      act.game = game
      act.save!
    else
      game.histories.create!(:event => "Swindler could not make #{target.name} trash a card, as they have an empty deck.",
                            :css_class => "player#{target.seat} card_trash")
    end

    return "OK"
  end

  def resolve_choose(ply, params, parent_act)
    # We expect to have been passed either :nil_action or a :pile_index
    if (not params.include? :nil_action) and (not params.include? :pile_index)
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a buy; code shamelessly yoinked from
    # Player.buy.
    if ((params.include? :pile_index) and
           (params[:pile_index].to_i < 0 or
            params[:pile_index].to_i > game.piles.length - 1))
      # Asked to give an invalid card (out of range)
      return "Invalid request - pile index #{params[:pile_index]} is out of range"
    elsif params.include? :pile_index and game.piles[params[:pile_index].to_i].cost != params[:trashed_cost].to_i
      # Asked to give an invalid card (wrong cost)
      return "Invalid request - card #{game.piles[params[:pile_index].to_i].card_type} is the wrong cost"
    elsif params.include? :nil_action and game.piles.any? {|p| p.cost == params[:trashed_cost].to_i and not p.empty?}
      return "Invalid request - must choose a card if possible"
    end

    target = Player.find(params[:target].to_i)
    if params[:nil_action]
      # Player has chosen to give nothing.
      game.histories.create!(:event => "#{ply.name} gave #{target.name} no replacement card.",
                            :css_class => "player#{ply.seat} player#{target.seat}")
    else
      # Process the choice. Move the chosen card to the top of the target's discard pile
      # Get the card to do it, so that we mint a fresh instance of infinite cards
      game.histories.create!(:event => "#{ply.name} gave #{target.name} a " +
             "#{game.piles[params[:pile_index].to_i].card_class.readable_name} in exchange.",
                            :css_class => "player#{ply.seat} player#{target.seat} card_gain")
      target.gain(parent_act, game.piles[params[:pile_index].to_i].id)
    end

    return "OK"
  end
end
