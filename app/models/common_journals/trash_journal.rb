module CommonJournals
  class TrashJournal < Journal
    def self.configure(question_text: nil, question_block: nil, filter: nil)
      define_question(question_text, &question_block).with_controls do |_game_state|
        [OneCardControl.new(journal_type: journal_type,
                            question:     self,
                            player:       @player,
                            scope:        :hand,
                            text:         'Trash',
                            filter:       filter,
                            # If the card to trash has conditions, it's legal to trash
                            # nothing, to avoid trust issues.
                            null_choice:  if @player.hand_cards.empty? || filter
                                            { text: 'Trash nothing', value: 'none' }
                                          end,
                            css_class:    'trash-card')]
      end
    end

    validation do
      return false if journal.params['choice'] == 'none' && @player.hand_cards.present?
      return true if journal.params['choice'] == 'none'
      return false unless journal.params['choice']&.integer?
      return false if journal.params['choice'].to_i >= journal.player.hand_cards.length

      !filter || instance_exec(journal.player.hand_cards[journal.params['choice'].to_i], &filter)
    end

    process do |_game_state|
      if params['choice'] == 'none'
        @histories << GameEngine::History.new("#{player.name} trashed nothing.",
                                              player:      player,
                                              css_classes: %w[trash-card])
        return
      end

      # Trash the chosen card from its owner's hand
      card = player.hand_cards[params['choice'].to_i]
      @card_cost = card.cost
      @histories << GameEngine::History.new("#{player.name} trashed #{card.readable_name} from their hand.",
                                            player:      player,
                                            css_classes: %w[trash-card])
      card.trash(from: player.cards)
      observe

      post_process if respond_to?(:post_process)
    end
  end
end