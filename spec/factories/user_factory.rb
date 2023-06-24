FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    password { 's3kr3tw0rd' }
    sequence :name, %w[Alan Belle Chas Donna Evan].cycle
  end
end
