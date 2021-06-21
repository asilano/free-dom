module GameEngine
  module Renaissance
    class BorderGuard < Card
      text 'Action (cost: 2)',
           '+1 Action',
           'Reveal the top 2 cards of your deck. Put one into your hand and discard the other. If both were Actions, take the Lantern or Horn.'
      action
      costs 2

      # Horn - Once per turn, when you discard a Border Guard from play, you may put it onto your deck.
      # Lantern - Border Guards you play reveal 3 cards and discard 2. (It takes all 3 being Actions to take the Horn.)

      setup do |game_state|
        CardlikeObjects::Horn.new(game_state)
        CardlikeObjects::Lantern.new(game_state)
      end

      def play_as_action(played_by:)
        super

        played_by.grant_actions(1)

        game_state.get_journal(ChooseCardForHandJournal,
                               from:           played_by,
                               revealed_cards: played_by.reveal_cards(2, from: :deck))
                  .process(game_state)
      end

      class ChooseCardForHandJournal < Journal
        define_question('Choose a card to put into your hand').with_controls do |_game_state|
          [OneCardControl.new(journal_type: journal_type,
                              question:     self,
                              player:       @player,
                              scope:        :revealed,
                              text:         'Choose',
                              null_choice:  if @player.cards_revealed_to(self).empty?
                                              { text: 'Choose nothing', value: 'none' }
                                            end)]
        end

        validation do
          return true if player.cards_revealed_to(question).empty? && journal.params['choice'] == 'none'
          return false if player.cards_revealed_to(question).present? && journal.params['choice'] == 'none'
          return false unless journal.params['choice']&.integer?

          choice = journal.params['choice'].to_i
          choice < journal.player.cards_revealed_to(question).length
        end

        process do |game_state|
          take_artifact = player.cards_revealed_to(@question).count(&:action?) == 2

          # Done looking at cards. Trash up to one, and discard the rest!
          if params['choice'] == 'none'
            @histories << History.new("#{player.name} put nothing into their hand.",
                                      player:      player)
          else
            # Put the chosen card into the player's hand.
            card = player.cards_revealed_to(@question)[params['choice'].to_i]
            @histories << History.new("#{player.name} put #{card.readable_name} into their hand.",
                                      player: player)
            card.be_unrevealed
            card.move_to_hand
          end

          # Discard any remaining revealed cards.
          if player.cards_revealed_to(@question).present?
            @histories << History.new("#{player.name} discarded #{player.cards_revealed_to(@question).map(&:readable_name).join(', ')} from their deck.",
                                      player:      player,
                                      css_classes: %w[discard-card])
            player.cards_revealed_to(@question).each(&:be_unrevealed).each(&:discard)
          end

          observe

          game_state.get_journal(TakeArtifactJournal, from: player).process(game_state) if take_artifact
        end
      end

      class TakeArtifactJournal < Journal
        define_question('Take Lantern or Horn').with_controls do |game_state|
          opts = [["Take the Lantern#{' (you already have it)' if game_state.lantern_owner == @player}", 'lantern']]
          opts << ["Take the Horn#{' (you already have it)' if game_state.lantern_owner == @player}", 'horn']
          [ButtonControl.new(journal_type: journal_type,
                             question:     self,
                             player:       @player,
                             scope:        :player,
                             values:       opts)]
        end

        validation do
          %w[lantern horn].include? journal.params['choice']
        end

        process do |game_state|
          game_state.set_fact(:"#{params['choice']}_owner", player)

          @histories << History.new("#{player.name} took the #{params['choice'].titleize}.",
                                    player: player)
        end
      end
    end
  end
end
