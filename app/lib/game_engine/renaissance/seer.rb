module GameEngine
  module Renaissance
    class Seer < Card
      text "+1 Card",
           "+1 Action",
           "Reveal the top 3 cards of your deck. Put the ones costing from $2 to $4 into your hand. Put the rest back in any order."
      action
      costs 5

      def play(played_by:)
        played_by.draw_cards(1)
        played_by.grant_actions(1)

        revealed_cards = played_by.reveal_cards(3, from: :deck)
        mid_cards, remnant = revealed_cards.partition { (2..4).cover? _1.cost }
        mid_cards.each(&:move_to_hand)

        if remnant.length > 1
          game_state.get_journal(ReorderJournal,
                                 from:           player,
                                 revealed_cards: remnant).process(game_state)
        else
          remnant.each(&:be_unrevealed)
        end
      end

      class ReorderJournal < Journal
        define_question('Reorder the cards on top of your deck').with_controls do |_game_state|
          cards = @player.deck_cards.select(&:revealed)
          [ReorderCardsControl.new(journal_type: ReorderJournal,
                                   question:     self,
                                   player:       @player,
                                   scope:        :revealed,
                                   filter:       ->(card) { cards.include? card },
                                   count:        cards.count,
                                   submit_text:  'Submit',
                                   css_class:    'reorder')]
        end

        validation do
          choice = params['choice']
          return false unless choice.is_a? Hash
          return false unless choice.keys.all?(&:integer?)
          return false unless choice.keys.map(&:to_i).sort == (0...player.revealed_cards.length).to_a

          choice.values.map(&:to_i).sort == (1..player.revealed_cards.length).to_a
        end

        process do |_game_state|
          cards = player.revealed_cards
          indices = cards.map { |c| player.cards.index(c) }

          cards.sort_by!.with_index { |_, ix| params['choice'][ix.to_s].to_i }
          indices.zip(cards).each { |ix, c| player.cards[ix] = c }

          cards.each(&:be_unrevealed)
          @histories << History.new("#{player.name} reordered the top #{cards.length} cards of their deck.",
                                    player:      player,
                                    css_classes: %w[reorder])
        end
      end
    end
  end
end
