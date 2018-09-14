FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "person#{n}@example.com" }
    password { 's3kr3tw0rd' }
    name { 'Joe Bloggs' }
  end
end
