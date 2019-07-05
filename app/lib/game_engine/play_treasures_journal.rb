module GameEngine
  class PlayTreasuresJournal < Journal
    define_question('Play Treasures, or pass').with_controls do |_game_state|
      [MultiCardControl.new(player: @player,
                            scope: :hand,
                            text: 'Play',
                            filter: ->(card) { card.treasure? },
                            preselect: ->(card) { !card.special? },
                            submit_text: 'Play selected treasures (select none to stop)',
                            css_class: 'play-treasure')]
    end

    validation do
      journal.params['choice'].all? do |choice|
        choice.to_i < journal.player.hand_cards.length &&
          journal.player.hand_cards[choice.to_i].treasure?
      end
    end

    def process(game_state)
      super

      # return :stop if params['choice'].blank?

      cards = params['choice'].map { |ch| player.hand_cards[ch.to_i] }
      cards.each do |card|
        player.in_play_cards << card
        player.hand_cards.delete card
        player.cash += card.cash
      end

      :continue
    end
  end
end
