module CommonJournals
  class GainJournal < Journal
    attr_reader :card

    def self.configure(question_text:  nil,
                       question_block: nil,
                       filter:         nil,
                       destination:    :discard)
      define_question(question_text, &question_block).with_controls do |game_state|
        bound_filter = ->(*args) { instance_exec(*args, &filter) } if filter
        [OneCardControl.new(journal_type: journal_type,
                            question:     self,
                            player:       @player,
                            scope:        :supply,
                            text:         'Gain',
                            filter:       filter,
                            null_choice:  if filter && game_state.piles.map(&:cards).map(&:first).none?(&bound_filter)
                                            { text: 'Gain nothing', value: 'none' }
                                          end,
                            css_class:    'gain-card')]
      end

      process do |game_state|
        if params['choice'] == 'none'
          @histories << GameEngine::History.new("#{player.name} gained nothing.",
                                                player:      player,
                                                css_classes: %w[gain-card])
        else
          pile = game_state.piles[params['choice'].to_i]
          @card = pile.cards.first

          @histories << GameEngine::History.new("#{player.name} gained #{card.readable_name}#{" to their #{destination}" unless destination == :discard}.",
                                                player:      player,
                                                css_classes: %w[gain-card])
          card.be_gained_by(player, from: pile.cards, to: destination)
          observe
        end

        post_process if respond_to?(:post_process)
      end
    end
  end
end
