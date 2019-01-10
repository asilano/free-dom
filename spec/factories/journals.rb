FactoryBot.define do
  factory :journal do
    game
    user
    order { 1 }
    type { Journal }
    params { '' }
  end
end
