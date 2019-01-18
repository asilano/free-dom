FactoryBot.define do
  factory :journal do
    game
    user
    sequence(:order)
    type { Journal }
    params { '' }
  end
end
