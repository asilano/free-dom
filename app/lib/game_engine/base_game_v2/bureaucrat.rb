module GameEngine
  module BaseGameV2
    class Bureaucrat < GameEngine::Card
      text 'Action/Attack (cost: 4)',
           'Gain a Silver onto your deck.',
           'Each other player reveals a Victory card from their hand and' \
           ' puts it onto their deck (or reveals a hand with no Victory cards).'
      action
      attack
      costs 4
    end
  end
end
