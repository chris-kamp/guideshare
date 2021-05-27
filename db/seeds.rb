# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'uri'

User.destroy_all
Guide.destroy_all
Tag.destroy_all

# Seed users
user =
  User.create(
    email: 'user@user.com',
    username: 'user',
    password: ENV['SEED_USER_PASSWORD'],
    cart: Cart.new
  )
admin =
  User.create(
    email: 'admin@admin.com',
    username: 'admin',
    password: ENV['SEED_ADMIN_PASSWORD'],
    cart: Cart.new
  )
devtester =
  User.create(
    email: 'devtester9001@gmail.com',
    username: 'devtester',
    password: ENV['SEED_DEVTESTER_PASSWORD'],
    cart: Cart.new
  )
anon1 =
  User.create(
    email: 'anon1@anon1.com',
    username: 'anon1',
    password: "anon1aaa",
    cart: Cart.new
  )
anon2 =
  User.create(
    email: 'anon2@anon2.com',
    username: 'anon2',
    password: "anon1aaa",
    cart: Cart.new
  )
anon3 =
  User.create(
    email: 'anon3@anon3.com',
    username: 'anon3',
    password: "anon1aaa",
    cart: Cart.new
  )
anon4 =
  User.create(
    email: 'anon4@anon4.com',
    username: 'anon4',
    password: "anon1aaa",
    cart: Cart.new
  )
anon5 =
  User.create(
    email: 'anon5@anon5.com',
    username: 'anon5',
    password: "anon1aaa",
    cart: Cart.new
  )
anon6 =
  User.create(
    email: 'anon6@anon6.com',
    username: 'anon6',
    password: "anon1aaa",
    cart: Cart.new
  )
anon7 =
  User.create(
    email: 'anon7@anon7.com',
    username: 'anon7',
    password: "anon1aaa",
    cart: Cart.new
  )

# Seed tags

tags = Tag.create([
  {
    name: "DIY"
  },
  {
    name: "Tech"
  },
  {
    name: "Health & Fitness"
  },
  {
    name: "Arts & Crafts"
  },
  {
    name: "Finance"
  },
  {
    name: "Cooking"
  },
  {
    name: "Productivity"
  },
  {
    name: "Short"
  },
  {
    name: "Long"
  },
  {
    name: "Beginner"
  },
  {
    name: "Intermediate"
  },
  {
    name: "Expert"
  },
])

# To avoid excessive Cloudinary requests, when seeding, load one attachment and replicate for other seeded guides.
guide_attachment = File.open(File.join(Rails.root, 'app/assets/documents/lorem.pdf'))

guide_template =
  user.guides.create(
    title: "User's first guide",
    description: 'The very first guide',
    guide_file: {
      io: guide_attachment,
      filename: 'lorem.pdf',
    },
    price: 1.5,
    tags: [tags[0], tags[3]]
  )

# Seed guides for each user
user.guides.create(
  [
    {
      title: 'Guide with no description',
      guide_file: guide_template.guide_file.blob,
      tags: [tags[0], tags[3]],
      price: 10.5
    },
    {
      title: 'Guide 3',
      description: 'This is the description',
      guide_file: guide_template.guide_file.blob,
      price: 0,
      tags: [tags[1], tags[10]]
    },
  ],
)
admin.guides.create(
  [
    {
      title: 'Another guide',
      description: "This one's by the admin",
      guide_file: guide_template.guide_file.blob,
      price: 5.5,
      tags: [tags[0], tags[4], tags[7]]
    },
    {
      title: 'Another admin guide with a long description',
      description:
        'This is a long description to see what that looks like. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus.',
      guide_file: guide_template.guide_file.blob,
      price: 1
    },
  ],
)
devtester.guides.create(
  [
    {
      title: 'Definitely a guide',
      description: "Pretty sure it's a guide",
      guide_file: guide_template.guide_file.blob,
      price: 25,
      tags: [tags[7], tags[10], tags[2]]
    },
    {
      title:
        "This is a guide with a very long title that is the max length 120 characters long, almost, but doesn't quite get there",
      description: 'This is a short description of a guide with a long title',
      guide_file: guide_template.guide_file.blob,
      price: 9.95,
      tags: [tags[6], tags[7]]
    },
    {
      title: 'Running out of titles',
      guide_file: guide_template.guide_file.blob,
      tags: [tags[9], tags[5]],
      price: 4.5
    },
  ],
)

devtester.guides.first.reviews.create(content: "Anon 1's review", rating: 5, user: anon1)
devtester.guides.first.reviews.create(content: "Anon 2's review", rating: 2, user: anon2)
devtester.guides.first.reviews.create(content: "Anon 3's review", rating: 3, user: anon3)
devtester.guides.first.reviews.create(content: "Anon 4's review", rating: 4, user: anon4)
devtester.guides.first.reviews.create(content: "Anon 5's review", rating: 5, user: anon5)
devtester.guides.first.reviews.create(content: "Anon 6's review", rating: 0, user: anon6)
devtester.guides.first.reviews.create(content: "Anon 7's review", rating: 2, user: anon7)
