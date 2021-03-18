module PlayerModules
  module Manipulation
    def draw_cards(num)
      shuffle_discard_under_deck if deck_cards.length < num && discarded_cards.present?
      drawn_cards = deck_cards.take(num)
      if drawn_cards.blank?
        @game.current_journal.histories << GameEngine::History.new("#{name} drew no cards.",
                                                                   player:      self,
                                                                   css_classes: %w[draw-cards])
        return
      end

      @game.fix_journal
      @game.current_journal.histories << GameEngine::History.new(
        "#{name} drew #{GameEngine::History.personal_log(private_to:  user,
                                                         private_msg: drawn_cards.map(&:readable_name).join(', '),
                                                         public_msg:  "#{drawn_cards.length} #{'card'.pluralize(drawn_cards.length)}")}.",
        player:      self,
        css_classes: %w[draw-cards]
      )
      drawn_cards.each(&:be_drawn)
    end

    def shuffle_discard_under_deck
      discards, other = cards.partition { |c| c.location == :discard }
      @cards = other + discards.shuffle(random: game_state.rng).each { |c| c.location = :deck }
      @game.current_journal.histories << GameEngine::History.new("#{name} shuffled their discards.",
                                                                 player:      self,
                                                                 css_classes: %w[shuffle])
    end

    def reveal_cards(num, from:)
      num = cards_by_location(from).length if num == :all
      shuffle_discard_under_deck if from == :deck && deck_cards.length < num && discarded_cards.present?
      revealed_cards = cards_by_location(from).take(num)
      if revealed_cards.blank?
        @game.current_journal.histories << GameEngine::History.new("#{name} revealed no cards.",
                                                                   player:      self,
                                                                   css_classes: %w[reveal-cards])
        return []
      end

      @game.fix_journal
      @game.current_journal.histories << GameEngine::History.new(
        "#{name} revealed #{revealed_cards.map(&:readable_name).join(', ')}",
        player:      self,
        css_classes: %w[reveal-cards]
      )
      revealed_cards.each(&:be_revealed)
    end

    def peek_cards(num, from:)
      num = cards_by_location(from).length if num == :all
      shuffle_discard_under_deck if from == :deck && deck_cards.length < num && discarded_cards.present?
      peeked_cards = cards_by_location(from).take(num)
      if peeked_cards.blank?
        @game.current_journal.histories << GameEngine::History.new("#{name} looked at no cards.",
                                                                   player:      self,
                                                                   css_classes: %w[peek-cards])
        return []
      end

      @game.fix_journal
      @game.current_journal.histories << GameEngine::History.new(
        "#{name} looked at #{GameEngine::History.personal_log(private_to:  user,
                                                              private_msg: peeked_cards.map(&:readable_name).join(', '),
                                                              public_msg:  "#{peeked_cards.length} #{'card'.pluralize(peeked_cards.length)}"
                                                             )}.",
        player:      self,
        css_classes: %w[peek-cards]
      )
      peeked_cards.each(&:be_peeked)
    end

    def discard_cards(num, from:)
      num = cards_by_location(from).length if num == :all
      shuffle_discard_under_deck if from == :deck && deck_cards.length < num && discarded_cards.present?
      discards = cards_by_location(from).take(num)
      @game.current_journal.histories << GameEngine::History.new(
        "#{name} discarded #{discards.map(&:readable_name).join(', ')}"
      )
      discards.each(&:discard)
    end

    def grant_actions(num)
      @actions += num
    end

    def grant_buys(num)
      @buys += num
    end

    def grant_cash(num)
      @cash += num
    end
  end
end
