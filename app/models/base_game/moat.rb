class BaseGame::Moat < Card
  costs 2
  action
  reaction
  trigger :do_moat, on: :attack, when: {location: 'hand'}
  card_text "Action (Reaction; cost: 2) - Draw 2 cards. When another player plays an " +
                                 "Attack card, you may reveal this from your " +
                                 "hand. If you do, you are unaffected by " +
                                 "that Attack."

  def play
    super

    # Just draw two cards
    player.draw_cards(2)
  end

  def determine_controls(actor, controls, question)

  end

  def do_moat(state)
    if (state[:victim] == player && state[:attacker] != player)
      # That the player has a Moat is hidden information, so apply
      # a journal block.
      game.apply_journal_block

      if game.find_journal("#{player.name} {{auto?}}eacted to attack with #{readable_name} ({{position}}).").nil? &&
        game.find_journal("#{player.name} didn't react to attack.").nil?
        if player.settings.automoat
          # Automoat active. Pre-create the journal
          game.add_journal(player_id: player.id,
                            event: "#{player.name} auto-reacted to attack with #{readable_name} (#{player.cards.hand.index(self)}).")
        end
      end

      # Mark ourselves so that Player can handle reacting with a single control
      player.register_reaction(self, :attack, state)
    end
  end

  def react(journal)
    # Everything looks fine. Moat the attack (by removing the conduct-attack question)
    # if revealed.
    journal.params[:att_q].andand.delete
    journal.params[:att_j].andand.delete
    if journal =~ /#{player.name} auto-reacted/
      can_react_to.delete(:attack)
    end
  end
end
