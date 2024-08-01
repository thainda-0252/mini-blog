FactoryBot.define do
  factory :user do
    username { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "Abc1234@" }
    password_confirmation { "Abc1234@" }
    bio { Faker::Lorem.paragraph }
  end
end
