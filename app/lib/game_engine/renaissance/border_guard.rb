module GameEngine
  module Renaissance
    class BorderGuard < Card
      text '+1 Action',
           'Reveal the top 2 cards of your deck. Put one into your hand and discard the other. If both were Actions, take the Lantern or Horn.'
      action
      costs 2

      # Horn - Once per turn, when you discard a Border Guard from play, you may put it onto your deck.
      # Lantern - Border Guards you play reveal 3 cards and discard 2. (It takes all 3 being Actions to take the Horn.)

      setup do |game_state|
        game_state.create_artifact(CardlikeObjects::Artifacts::Horn)
        game_state.create_artifact(CardlikeObjects::Artifacts::Lantern)
      end

      def play_as_action(played_by:)
        super

        played_by.grant_actions(1)

        lantern = game_state.artifacts['Lantern'].owned_by?(played_by)
        cards_to_reveal = lantern ? 3 : 2
        game_state.get_journal(ChooseCardForHandJournal,
                               from:           played_by,
                               revealed_cards: played_by.reveal_cards(cards_to_reveal, from: :deck),
                               opts:           {lanterned: lantern})
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
          return true if player.cards_revealed_to(question).empty? && params['choice'] == 'none'
          return false if player.cards_revealed_to(question).present? && params['choice'] == 'none'
          return false unless params['choice']&.integer?

          choice = params['choice'].to_i
          choice < player.cards_revealed_to(question).length
        end

        process do |game_state|
          take_artifact = player.cards_revealed_to(@question).count(&:action?) == (opts[:lanterned] ? 3 : 2)

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
          opts = [["Take the Lantern#{' (you already have it)' if game_state.artifacts['Lantern'].owned_by?(@player)}", 'Lantern']]
          opts << ["Take the Horn#{' (you already have it)' if game_state.artifacts['Horn'].owned_by?(@player)}", 'Horn']
          [ButtonControl.new(journal_type: journal_type,
                             question:     self,
                             player:       @player,
                             scope:        :player,
                             values:       opts)]
        end

        validation do
          %w[Lantern Horn].include? params['choice']
        end

        process do |game_state|
          game_state.artifacts[params['choice']].give_to(player)

          @histories << History.new("#{player.name} took the #{params['choice']}.",
                                    player: player)
        end
      end
    end
  end
end
