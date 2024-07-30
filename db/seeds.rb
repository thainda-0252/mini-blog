Post.destroy_all

30.times do
  Post.create(
    caption: Faker::Lorem.paragraph,
    status: Faker::Number.between(from: 0, to: 1),
    user_id: Faker::Number.between(from: 1, to: 2)
  )
end
