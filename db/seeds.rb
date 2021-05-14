# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all
Guide.destroy_all

# Seed users
user =
  User.create(
    email: 'user@user.com',
    username: 'user',
    password: ENV['SEED_USER_PASSWORD'],
  )
admin =
  User.create(
    email: 'admin@admin.com',
    username: 'admin',
    password: ENV['SEED_ADMIN_PASSWORD'],
  )
devtester =
  User.create(
    email: 'devtester9001@gmail.com',
    username: 'devtester',
    password: ENV['SEED_DEVTESTER_PASSWORD'],
  )

# Seed guides for each user
user.guides.create(
  [
    { title: "User's first guide", description: 'The very first guide' },
    { title: 'Guide with no description' },
    { title: 'Guide 3', description: 'This is the description' },
  ],
)
admin.guides.create(
  [
    { title: 'Another guide', description: "This one's by the admin" },
    { title: 'Another admin guide without a description' },
  ],
)
devtester.guides.create(
  [
    { title: 'Definitely a guide', description: "Pretty sure it's a guide" },
    {
      title:
        "This is a guide with a very long title that is the max length 120 characters long, almost, but doesn't quite get there",
      description: 'This is a short description of a guide with a long title',
    },
    { title: 'Running out of titles' },
  ],
)
