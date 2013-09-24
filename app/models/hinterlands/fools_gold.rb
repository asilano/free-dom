class Hinterlands::FoolsGold < Card
  treasure :special => true
  reaction :to => :opponent_gain
  costs 2
  card_text "Treasure (Reaction; cost: 2) - If this is the first time you played a #{readable_name} this turn, this is worth 1 cash, otherwise it's worth 4 cash." +
            " / When another player gains a Province, you may trash this from your hand. If you do, gain a Gold, putting it on your deck."

  def self.readable_name
    "Fool's Gold"
  end

  def play_treasure(parent_act)
    # Get the superclass to move the card
    super

    # Now, grant the player 1 cash or 4, depending on whether this is the first FG or not.
    cash = player.state.played_fools_gold ? 4 : 1
    player.add_cash(cash)
    player.state.played_fools_gold = true
    player.state.save!

    game.histories.create!(:event => "#{self} granted #{player.name} #{cash} cash.",
                          :css_class => "player#{player.seat} play_treasure")
    "OK"
  end

  def determine_controls(player, controls, substep, params)
    case substep
    when "exchange"
      controls[:player] += [{:type => :buttons,
                             :label => "Trash #{self} to gain Gold:",
                             :params => {:card => "#{self.class}#{id}",
                                         :substep => "exchange"},
                             :options => [{:text => "Trash", :choice => "trash"},
                                          {:text => "Don't trash", :choice => "keep"}]
                            }]
    end
  end

  def self.witness_gain(params)
    return false unless params[:card].class == BasicCards::Province

    # Queue up appropriate actions for each Fool's Gold held by other players
    gainer = Player.find(params[:gainer])
    parent_act = params[:parent_act]

    gainer.other_players.each do |ply|
      ply.cards.hand.of_type("Hinterlands::FoolsGold").each do |fg|
        # For each Fool's Gold in everyone else's hand, work out
        # if it's to be trashed for a Gold
        if ply.settings.autofoolsgold == Settings::ALWAYS
          # Player is always trashing their Fool's Golds
          fg.resolve_exchange(ply, {:choice => 'trash'}, parent_act)
        elsif ply.settings.autofoolsgold == Settings::NEVER
          # Player is never trashing their Fool's Golds.
          # Do nothing; the FG is in a hidden location
        else
          parent_act.children.create(:expected_action => "resolve_#{fg.class}#{fg.id}_exchange",
                                     :text => "Decide whether to exchange #{fg.readable_name} for Gold",
                                     :game => ply.game,
                                     :player => ply)
        end
      end
    end

    # Fool's Gold does not impact the Province's gain
    return false
  end

  def resolve_exchange(ply, params, parent_act)
    # This is the player choosing whether to exchange their Fool's Gold for a Gold
    # We expect to have a :choice parameter, either "trash" or "keep"
    if (!params.include? :choice) ||
       (!params[:choice].in? ["trash", "keep"])
      return "Invalid parameters"
    end

    if params[:choice] == "trash"
      # Player chose to trash, and therefore gain a Gold
      game.histories.create(:event => "#{ply.name} chose to trash #{self} from hand, and gained a Gold.",
                            :css_class => "player#{ply.seat} card_gain card_trash")

      trash
      ply.gain(parent_act, :pile => game.piles.find_by_card_type("BasicCards::Gold"))
    else
      # Don't log. Technically, this is secret.
    end
  end
end