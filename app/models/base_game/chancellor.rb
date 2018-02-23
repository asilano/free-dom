class BaseGame::Chancellor < Card
  costs 3
  action
  card_text "Action (cost: 3) - +2 Cash. You may immediately put your deck into your " +
                        "discard pile."

  module Journals
    class ChooseDiscardJournal < Journal
      causes :choice
      validates_hash_keys :parameters do
        validates :choice, inclusion: { in: %w[discard keep] }
      end
      text { "#{player.name} chose to #{parameters[:choice]} their deck with Chancellor." }
      question(text: 'Choose whether to discard your deck with Chancellor') do
        {
          player: {
            type: :buttons,
            label: "Chancellor:",
            options: [{ text: 'Discard deck', choice: 'discard' },
                      { text: "Don't discard", choice: 'keep' }]
          }
        }
      end
    end
  end
  ChooseEventTempl = Journal::Template.new("{{player}} chose to {{choice}} their deck with #{readable_name}.")

  def play
    super

    # Easy bit first. Add two cash
    player.cash += 2

    # Ask the required question
    game.ask_question(object: self, actor: player, journal: Journals::ChooseDiscardJournal)
  end

  def choice(journal)
    if journal.parameters[:choice] == 'discard'
      journal.player.cards.deck.each do |card|
        # Move card to discard _without tripping callbacks_
        card.location = 'discard'
      end
    end
  end
end
