module GameEngine
  class PlayerState
    attr_reader :user, :cards, :game_state, :game
    attr_accessor :seat, :actions, :buys, :cash, :score

    def initialize(user, game_state)
      @user = user
      @game_state = game_state
      @game = game_state.game
      @cards = []
      @score = 0
    end

    def name
      @user.name
    end

    # Inspectors
    def cards_by_location(location)
      @cards.select { |c| c.location == location }
    end

    def deck_cards
      cards_by_location(:deck)
    end

    def hand_cards
      cards_by_location(:hand)
    end

    def played_cards
      cards_by_location(:play)
    end

    def discarded_cards
      cards_by_location(:discard)
    end

    def revealed_cards
      cards.select(&:revealed)
    end

    def peeked_cards
      cards.select(&:peeked)
    end

    def cards_revealed_to(question)
      revealed_cards.select { |c| c.interacting_with == question }
    end

    def cards_peeked_to(question)
      peeked_cards.select { |c| c.interacting_with == question }
    end

    def other_players
      @game_state.players.reject { |p| p == self }
    end

    # Actors
    def draw_cards(num)
      shuffle_discard_under_deck if deck_cards.length < num && discarded_cards.present?
      drawn_cards = deck_cards.take(num)
      if drawn_cards.blank?
        @game.current_journal.histories << History.new("#{name} drew no cards.",
                                                       player: self,
                                                       css_classes: %w[draw-cards])
        return
      end

      @game.fix_journal
      @game.current_journal.histories << History.new(
        "#{name} drew #{History.personal_log(private_to:  user,
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
      @game.current_journal.histories << History.new("#{name} shuffled their discards.",
                                                     player:      self,
                                                     css_classes: %w[shuffle])
    end

    def reveal_cards(num, from:)
      num = cards_by_location(from).length if num == :all
      shuffle_discard_under_deck if from == :deck && deck_cards.length < num && discarded_cards.present?
      revealed_cards = cards_by_location(from).take(num)
      if revealed_cards.blank?
        @game.current_journal.histories << History.new("#{name} revealed no cards.",
                                                       player: self,
                                                       css_classes: %w[reveal-cards])
        return []
      end

      @game.fix_journal
      @game.current_journal.histories << History.new(
        "#{name} revealed #{revealed_cards.map(&:readable_name).join(', ')}",
        player: self,
        css_classes: %w[reveal-cards]
      )
      revealed_cards.each(&:be_revealed)
    end

    def peek_cards(num, from:)
      num = cards_by_location(from).length if num == :all
      shuffle_discard_under_deck if from == :deck && deck_cards.length < num && discarded_cards.present?
      peeked_cards = cards_by_location(from).take(num)
      if peeked_cards.blank?
        @game.current_journal.histories << History.new("#{name} looked at no cards.",
                                                       player: self,
                                                       css_classes: %w[peek-cards])
        return []
      end

      @game.fix_journal
      @game.current_journal.histories << History.new(
        "#{name} looked at #{History.personal_log(private_to: user,
                                                  private_msg: peeked_cards.map(&:readable_name).join(', '),
                                                  public_msg: "#{peeked_cards.length} #{'card'.pluralize(peeked_cards.length)}"
                                                  )}.",
        player: self,
        css_classes: %w[peek-cards]
      )
      peeked_cards.each(&:be_peeked)
    end

    def discard_cards(num, from:)
      num = cards_by_location(from).length if num == :all
      shuffle_discard_under_deck if from == :deck && deck_cards.length < num && discarded_cards.present?
      discards = cards_by_location(from).take(num)
      @game.current_journal.histories << History.new(
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

    # Processors
    def calculate_score
      @score += cards.select(&:victory?).map(&:points).sum
    end

    def decklist
      list = cards.group_by(&:class).map do |klass, cs|
        exemplar = cs.first
        entry = {
          types: exemplar.class.types,
          count: cs.count,
          name:  klass.readable_name,
          text:  exemplar.try(:text),
          last:  false
        }
        entry[:score] = exemplar.points if exemplar.respond_to?(:points)
        entry[:cash] = exemplar.cash if exemplar.respond_to?(:cash)
        entry
      end
      list.sort_by! do |exemplar|
        [-(exemplar[:score] || -Float::INFINITY),
         -(exemplar[:cash] || -Float::INFINITY),
         exemplar[:name]]
        # next 0 unless a[:score] || b[:score]
        # next 1 if a[:score].nil?
        # next -1 if b[:score].nil?
        # b[:score] <=> a[:score]
      end
      list.last[:last] = true
      list
    end
  end

end
