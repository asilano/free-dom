FactoryBot.define do
  factory :one_card_control do
    transient do
      player { build(:player_state) }
      base_opts { { journal_type: Journal, scope: :hand, player: } }
    end
    opts { base_opts }

    initialize_with { new(opts) }

    trait :with_no_card_control do
      opts { base_opts.merge({ null_choice: { text: "No card", value: "none" } }) }
    end
  end
end
