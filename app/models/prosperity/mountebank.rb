# Mountebank (Action - Attack - $5) - +2 Cash. Each other player may discard a Curse. If he doesn't, he gains a Curse and a Copper.

class Prosperity::Mountebank < Card
  action :attack => true,
         :order_relevant => lambda {|params|
           curses_pile = game.piles.find_by_card_type("BasicCards::Curse")
           curses_pile.cards.length < game.players.length - 1}
  costs 5
  card_text "Action (Attack; cost: 5) - +2 Cash. Each other player may discard a Curse. If he doesn't, he gains a Curse and a Copper."

  def play(parent_act)
    super

    player.cash += 2
    player.save!

    attack(parent_act)

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    determine_react_controls(player, controls, substep, params)

    case substep
    when "discard"
      # This is the target choosing a Curse to discard
      controls[:hand] += [{:type => :button,
                           :action => :resolve,
                           :text => "Discard",
                           :nil_action => "Discard nothing",
                           :params => {:card => "#{self.class}#{id}",
                                       :substep => "discard"},
                           :cards => player.cards.hand.map {|c| c.is_curse?}
                          }]
    end
  end

  def attackeffect(params)
    # Effect of the attack succeeding - that is, ask the target to discard
    # a Curse if they have one.
    target = Player.find(params[:target])
    # source = Player.find(params[:source])
    parent_act = params[:parent_act]

    if target.cards.hand.of_type("BasicCards::Curse").empty?
      # Target has no Curses; therefore they can't discard any, and we should
      # just call resolve_discard with :nil_action directly
      return resolve_discard(target, {:nil_action => true}, parent_act)
    else
      if target.settings.automountebank
        # AutoMountebank is on. Call resolve_discard directly, to avoid code duplication
        ix = target.cards.hand.index {|c| c.class == BasicCards::Curse}
        return resolve_discard(target, {:card_index => ix}, parent_act)
      else
        parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}_discard",
                                   :text => "Discard a Curse.",
                                   :player => target,
                                   :game => game)
      end
    end

    return "OK"
  end

  def resolve_discard(ply, params, parent_act)
    # This is at the attack target either discarding or not a Curse card.
    # We should expect a :card_index or a :nil_action parameter
    if (not params.include? :nil_action) && (!params.include? :card_index)
      return "Invalid parameters"
    end

    # Processing is pretty much the same as a Play; code shamelessly yoinked from
    # Player.play_action.
    if ((params.include? :card_index) &&
        (params[:card_index].to_i < 0 ||
         params[:card_index].to_i > ply.cards.hand.length - 1))
      # Asked to discard an invalid card (out of range)
      return "Invalid request - card index #{params[:card_index]} is out of range"
    elsif params.include?(:card_index) &&
          !ply.cards.hand[params[:card_index].to_i].is_curse?
      # Asked to discard an invalid card (not a Curse card)
      return "Invalid request - card index #{params[:card_index]} is not a Curse card"
    end

    # All looks good - process the request
    if params.include? :nil_action
      # :nil_action specified. Give the player a Curse and a Copper
      game.histories.create!(:event => "#{ply.name} didn't discard a Curse card, and gains a Curse and a Copper.",
                            :css_class => "player#{ply.seat} card_gain")
      curses_pile = game.piles.find_by_card_type("BasicCards::Curse")
      if not curses_pile.empty?
        ply.gain(parent_act, :pile => curses_pile)
      else
        game.histories.create!(:event => "#{ply.name} couldn't gain a Curse - none left.",
                              :css_class => "player#{ply.seat}")
      end

      copper_pile = game.piles.find_by_card_type("BasicCards::Copper")
      ply.gain(parent_act, :pile => copper_pile)
    else
      # :card_index specified. Discard the specified card
      card = ply.cards.hand[params[:card_index].to_i]
      card.discard
      game.histories.create!(:event => "#{ply.name} discarded a Curse.",
                              :css_class => "player#{ply.seat} card_discard")
    end

    return "OK"
  end
end