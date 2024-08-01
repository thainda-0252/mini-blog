FactoryBot.define do
  factory :post do
    caption { "This is a sample caption" }
    status { 1 }
    association :user

    trait :published do
      status { 1 }
    end

    trait :unpublished do
      status { 0 }
    end
  end
end
