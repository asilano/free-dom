# KingsCourt (Action - $7) - You may choose an Action card in you hand. Play it three times

class Prosperity::KingsCourt < Card
  action
  costs 7
  card_text "Action (cost: 7) - You may choose an Action card in your hand. Play it three times."

  serialize :state

  def self.readable_name
    "King's Court"
  end

  # This is Throne Room * 1.5.

  # * On Play, ask the player to choose an Action card in hand - even if they only have one,
  #   since King's Court is actually optional
  # * On resolution of that choice, create three Game actions, children of
  #   each other; each to Resolve one third of King's Court, and carrying the chosen
  #   card's ID as a param
  # * On resolution of the Game actions, look up the specified card, and Play it
  def play(parent_act)
    super

    if !player.cards.hand.any?(&:is_action?)
      # Holding no action cards. Just log
      game.histories.create!(:event => "#{player.name} chose no action to treble.",
                            :css_class => "player#{player.seat}")
    else
      # Create a PendingAction to choose a card
      parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}",
                                 :text => "Choose a card to play with #{readable_name}",
                                 :player => player,
                                 :game => game)
    end

    return "OK"
  end

  def determine_controls(player, controls, substep, params)
    # This is the King's Court's controller choosing an Action card
    controls[:hand] += [{:type => :button,
                         :action => :resolve,
                         :text => "Choose",
                         :nil_action => "Choose Nothing",
                         :params => {:card => "#{self.class}#{id}"},
                         :cards => player.cards.hand.map do |card|
                           card.is_action?
                         end
                        }]
  end

  def resolve(ply, params, parent_act)
    # Player has made a choice of what card to play, three times.
    # We expect to have been passed a :card_index
    if !params.include?(:card_index) && !params.include?(:nil_action)
      return "Invalid parameters"
    end

    if params.include? :card_index
      # Processing is pretty much the same as a Play; code shamelessly yoinked from
      # Player.play_action.
      if ((params[:card_index].to_i < 0 ||
           params[:card_index].to_i > ply.cards.hand.length - 1))
        # Asked to play an invalid card (out of range)
        return "Invalid request - card index #{params[:card_index]} is out of range"
      elsif !ply.cards.hand[params[:card_index].to_i].is_action?
        # Asked to play an invalid card (not an reaction)
        return "Invalid request - card index #{params[:card_index]} is not an action"
      end

      # Now process the action chosen. Create three Game-level actions under the parent
      # to play that card.
      chosen = ply.cards.hand[params[:card_index].to_i]
      game.histories.create!(:event => "#{ply.name} chose #{chosen.class.readable_name} to treble.",
                            :css_class => "player#{ply.seat}#{" play_attack" if chosen.is_attack?}")
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}" +
                                                           "_playaction;" +
                                                           "type=#{chosen[:type]};id=#{chosen.id}",
                                                           :game => game)
      act = act.children.create!(:expected_action => "resolve_#{self.class}#{id}" +
                                                    "_playaction;" +
                                                    "type=#{chosen[:type]};id=#{chosen.id}",
                                                    :game => game)
      act.children.create!(:expected_action => "resolve_#{self.class}#{id}" +
                                                    "_playaction;" +
                                                    "type=#{chosen[:type]};id=#{chosen.id}",
                                                    :game => game)

      if chosen.is_duration?
        # Chosen card is a duration. That means King's Court should also endure
        # Because you can TR a KC, and choose two durations, we must make state
        # an array, and append to it.
        self.location = "enduring"
        self.state_will_change!
        self.state ||= []
        self.state << "#{chosen.class};#{chosen.id}"
      end

      save!
    else
      # Processing nil_action - no action chosen.
      game.histories.create!(:event => "#{ply.name} chose no action to treble.",
                             :css_class => "player#{ply.seat}")
    end

    return "OK"
  end

  def playaction(params)
    # This is one of the three Game-level actions created to play the chosen card
    # thrice. First, pick up the card.
    card_class = to_class(params[:type])
    card_id = params[:id].to_i
    card = card_class.find(card_id)
    parent_act = params[:parent_act]

    # By far the simplest thing to do is to call the play method of the card.
    # However, the card needs to belong to the player, and it may have been trashed
    # during the first play. Some cards care whether they're in trash (for instance
    # Mining Village), so leave it where it is but set the player.
    card.player = player
    return card.play(parent_act)
  end

  def end_duration(parent_act)
    super

    # King's Court coming off duration? That must mean it's attached to
    # one or more durations
    raise "#{readable_name} #{id} enduring without state!" if state.empty?

    state.each do |state_item|
      /([[:alpha:]]+::[[:alpha:]]+);([[:digit:]]+)/.match(state_item)
      card_type = $1
      card_id = $2

      card = card_type.constantize.find(card_id)

      if !card.is_duration?
        raise "#{readable_name} #{id} enduring without a duration attached!"
      end

      # Add in two game-level actions to re-end the duration of the attached card
      act = parent_act.children.create!(:expected_action => "resolve_#{self.class}#{id}" +
                                                     "_attachedduration;" +
                                                     "type=#{card_type};id=#{card_id}",
                                                     :game => game)
      act.children.create!(:expected_action => "resolve_#{self.class}#{id}" +
                                                     "_attachedduration;" +
                                                     "type=#{card_type};id=#{card_id}",
                                                     :game => game)
    end

    self.state = []
    save!

    return "OK"
  end

  def attachedduration(params)
    # This is the Game-level action created to get the end-of-duration effects
    # of the chosen card again.
    card_class = to_class(params[:type])
    card_id = params[:id].to_i
    card = card_class.find(card_id)
    parent_act = params[:parent_act]

    # By far the simplest thing to do is to call the end_duration method of the card.
    # That requires the card to be "enduring". Nothing else should need to be changed
    card.location = "enduring"
    return card.end_duration(parent_act)
  end
end