class BaseGame::Moat < Card
  costs 2
  action
  reaction
  trigger :do_moat, on: :attack, when: { location: 'hand' }
  card_text 'Action (Reaction; cost: 2) - Draw 2 cards. When another player plays an ' \
                                 'Attack card, you may reveal this from your ' \
                                 'hand. If you do, you are unaffected by ' \
                                 'that Attack.'

  module Journals
    class ReactJournal < Journal
    end
  end

  def play
    super

    # Just draw two cards
    player.draw_cards(2)
  end

  def do_moat(state)
    return unless state[:victim] == player && state[:attacker] != player

    # That the player has a Moat is hidden information, so apply
    # a journal block.
    game.apply_journal_block

    # Mark ourselves so that reacting can be handled with a single control
    react_q = register_reaction(:attack, state)

    return if game.find_journal(react_q[:template])
    return unless player.settings.automoat

    # Automoat active. Pre-create the journal
    game.add_journal(type: react_q[:question].parent,
                     player: player,
                     parameters: { card_id: id })
  end

  def react(journal)
    # Everything looks fine. Moat the attack (by removing the conduct-attack question)
    # if revealed.
    byebug
    state = YAML.safe_load(journal.parameters[:state])
    journal.parameters[:att_q].andand.delete
    journal.parameters[:att_j].andand.delete
    if journal =~ /#{player.name} auto-reacted/
      can_react_to.delete(:attack)
    end
  end
end
