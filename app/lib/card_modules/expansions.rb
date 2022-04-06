module CardModules
  module Expansions
    # The ever-present Victory cards
    BASIC_VICTORY_TYPES = %w[Estate Duchy Province Curse].map { |t| 'GameEngine::BasicCards::' + t }.freeze

    # The ever-present Treasure cards
    BASIC_TREASURE_TYPES = %w[Copper Silver Gold].map { |t| 'GameEngine::BasicCards::' + t }.freeze

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def expansions
        [GameEngine::BaseGameV2, GameEngine::Renaissance]
      end

      def randomised_cardlikes
        [GameEngine::CardlikeObjects::Projects]
      end

      def basic_victory_types
        BASIC_VICTORY_TYPES.map(&:constantize)
      end

      def basic_treasure_types
        BASIC_TREASURE_TYPES.map(&:constantize)
      end

      def all_card_types
        expansions.flat_map(&:card_classes) +
          basic_victory_types + basic_treasure_types
      end

      def all_kingdom_cards
        expansions.flat_map(&:kingdom_cards)
      end
    end
  end
end
