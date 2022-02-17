module GameEngine
  module BaseGameV2
    class Sentry < GameEngine::Card
      text '+1 Card',
           '+1 Action',
           'Look at the top 2 cards of your deck. Trash and/or discard any number of them.' \
           ' Put the rest back in any order.'
      action
      costs 5

      def play_as_action(played_by:)
        super

        played_by.draw_cards(1)
        observe
        played_by.grant_actions(1)

        if played_by.deck_cards.empty?
          game.current_journal.histories << History.new("#{played_by.name} has no cards in their deck.",
                                                        player:      played_by,
                                                        css_classes: %w[peek-cards])
        else
          game_state.get_journal(ScryJournal,
                                 from:         played_by,
                                 peeked_cards: played_by.peek_cards(2, from: :deck)).process(game_state)
        end
      end

      class ScryJournal < Journal
        define_question('Trash and/or discard cards on your deck').with_controls do |_game_state|
          [MultiCardChoicesControl.new(journal_type: ScryJournal,
                                       question:     self,
                                       player:       @player,
                                       scope:        :peeked,
                                       filter:       ->(card) { @player.deck_cards[0..2].include?(card) },
                                       choices:      {
                                         'Discard' => 'discard',
                                         'Trash'   => 'trash',
                                         'Keep'    => 'keep'
                                       },
                                       submit_text:  'Submit',
                                       css_class:    'scry')]
        end

        validation do
          choice = params['choice']
          return false unless choice.is_a? Hash
          return false unless choice.keys.all?(&:integer?)
          return false unless choice.keys.map(&:to_i).sort == (0...player.peeked_cards.length).to_a

          choice.values.all? { |v| %w[discard trash keep].include? v }
        end

        process do |game_state|
          log_middle = []
          log_classes = []
          player.peeked_cards.each.with_index do |card, ix|
            case params['choice'][ix.to_s]
            when 'discard'
              log_middle << "discarded #{card.readable_name}"
              log_classes << 'discard-card'
              card.be_unpeeked
              card.discard
            when 'trash'
              log_middle << "trashed #{card.readable_name}"
              log_classes << 'trash-card'
              card.be_unpeeked
              card.trash(from: player.cards)
            end
          end

          log_middle = ['discarded nothing and trashed nothing'] if log_middle.empty?
          @histories << History.new("#{player.name} #{log_middle.join(', ')}.",
                                    player:      player,
                                    css_classes: log_classes)
          observe

          if player.peeked_cards.length > 1
            game_state.get_journal(ReorderJournal,
                                   from:         player,
                                   peeked_cards: player.peeked_cards).process(game_state)
          else
            player.peeked_cards.each(&:be_unpeeked)
          end
        end
      end

      class ReorderJournal < Journal
        define_question('Reorder the cards on top of your deck').with_controls do |_game_state|
          cards = @player.deck_cards.select(&:peeked)
          [ReorderCardsControl.new(journal_type: ReorderJournal,
                                   question:     self,
                                   player:       @player,
                                   scope:        :peeked,
                                   filter:       ->(card) { cards.include? card },
                                   count:        cards.count,
                                   submit_text:  'Submit',
                                   css_class:    'reorder')]
        end

        validation do
          choice = params['choice']
          return false unless choice.is_a? Hash
          return false unless choice.keys.all?(&:integer?)
          return false unless choice.keys.map(&:to_i).sort == (0...player.peeked_cards.length).to_a

          choice.values.map(&:to_i).sort == (1..player.peeked_cards.length).to_a
        end

        process do |_game_state|
          cards = player.peeked_cards
          indices = cards.map { |c| player.cards.index(c) }

          cards.sort_by!.with_index { |_, ix| params['choice'][ix.to_s].to_i }
          indices.zip(cards).each { |ix, c| player.cards[ix] = c }

          cards.each(&:be_unpeeked)
          @histories << History.new("#{player.name} reordered the top #{cards.length} cards of their deck.",
                                    player:      player,
                                    css_classes: %w[reorder])
        end
      end
    end
  end
end
