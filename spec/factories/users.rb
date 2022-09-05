FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    password { 's3kr3tw0rd' }
    sequence(:name) { |n| %w[010101 Alan Belle Chas Donna Evan][n % 5] }
  end
end
