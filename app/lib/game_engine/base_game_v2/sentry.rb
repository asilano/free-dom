module GameEngine
  module BaseGameV2
    class Sentry < GameEngine::Card
      text 'Action (cost: 5)',
           '+1 Card',
           '+1 Action',
           'Look at the top 2 cards of your deck. Trash and/or discard any number of them.' \
           ' Put the rest back in any order.'
      action
      costs 5
    end
  end
end