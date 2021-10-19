module CommonJournals
  class TrashJournal < Journal
    def self.configure(question_text: nil, question_block: nil, scope: :hand, filter: nil)
      define_singleton_method(:filter) { filter }
      define_singleton_method(:scope) { scope }
      potential_cards = -> (player) do
        case scope
        when :hand
          player.hand_cards
        when :play
          player.played_cards
        end
      end
      define_singleton_method(:potential_cards, potential_cards)

      define_question(question_text, &question_block).with_controls do |_game_state|
        [OneCardControl.new(journal_type: journal_type,
                            question:     self,
                            player:       @player,
                            scope:        scope,
                            text:         'Trash',
                            filter:       filter,
                            # If the card to trash has conditions, it's legal to trash
                            # nothing, to avoid trust issues.
                            null_choice:  if potential_cards.call(@player).empty? || filter
                                            { text: 'Trash nothing', value: 'none' }
                                          end,
                            css_class:    'trash-card')]
      end
    end

    validation do
      potentials = self.class.potential_cards(player)
      return false if params['choice'] == 'none' &&
        !self.class.filter &&
        potentials.present?
      return true if params['choice'] == 'none'
      return false unless params['choice']&.integer?
      return false if params['choice'].to_i >= potentials.length

      !self.class.filter || instance_exec(potentials[params['choice'].to_i], &self.class.filter)
    end

    process do |_game_state|
      if params['choice'] == 'none'
        @histories << GameEngine::History.new("#{player.name} trashed nothing.",
                                              player:      player,
                                              css_classes: %w[trash-card])
        return
      end

      # Trash the chosen card from its owner's hand
      card = self.class.potential_cards(player)[params['choice'].to_i]
      @card_cost = card.cost
      @histories << GameEngine::History.new("#{player.name} trashed #{card.readable_name} from #{from_where}.",
                                            player:      player,
                                            css_classes: %w[trash-card])
      card.trash(from: player.cards)
      observe

      post_process if respond_to?(:post_process)
    end

    private

    def from_where
      case self.class.scope
      when :hand
        "their hand"
      end
    end
  end
end
