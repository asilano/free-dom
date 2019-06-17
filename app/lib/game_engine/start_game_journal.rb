module GameEngine
  class StartGameJournal < Journal
    define_question do |game_state|
      qn = 'Wait for more players'
      qn << ' or Start the game' if game_state.players.length > 1
      qn
    end.with_controls do |game_state|
      if game_state.players.length > 1
        [ButtonControl.new(player: @player,
                           scope: :player,
                           values: [['Start the game', 'start']])]
      else
        []
      end
    end

    def process(game_state)
      super
      game_state.state = :running
      @histories << History.new("#{user.name} started the game.")

      randomise_players(game_state)
      populate_piles(game_state)
      create_player_decks(game_state)
    end

    private

    def randomise_players(game_state)
      game_state.players.shuffle!.each.with_index do |player, ix|
        player.seat = ix + 1
        @histories << History.new("#{player.name} will play #{(ix + 1).ordinalize}.", css_class: "player#{ix + 1}")
      end
    end

    def populate_piles(game_state)
      game_state.piles.each do |pile|
        pile.fill_with Array.new(pile.card_class.starting_size(game_state.players.count)) { pile.card_class.new }
      end
    end

    def create_player_decks(game_state)
      copper_pile = game_state.piles.detect { |p| p.card_class == GameEngine::BasicCards::Copper }
      game_state.players.each do |player|
        # Deal 7 Coppers from the supply pile
        player.deck_cards.concat copper_pile.cards.shift(7)

        # Create 3 fresh Estates
        player.deck_cards.concat Array.new(3) { GameEngine::BasicCards::Estate.new }

        player.deck_cards.shuffle!
        player.hand_cards.concat player.deck_cards.shift(5)
      end
    end

    class Template
      def matches?(journal)
        return true if super && journal.game.users.length > 1
        return false unless journal.is_a? GameEngine::AddPlayerJournal
        define_singleton_method(:journal) { journal }
        valid? journal
      end
    end
  end
end
