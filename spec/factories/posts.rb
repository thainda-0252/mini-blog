FactoryBot.define do
  factory :post do
    caption { "This is a sample caption" }
    status { :published }
    association :user

    trait :published do
      status { :published }
    end

    trait :unpublished do
      status { :unpublished }
    end
  end
end
