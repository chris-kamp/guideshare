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

# To avoid excessive Cloudinary requests during testing, load one attachment and replicate for other seeded guides.
guide_attachment =
  URI.open(
    ENV['SAMPLE_PDF_FILE_LONG'],
  )

guide_template =
  user.guides.create(
    title: "User's first guide",
    description: 'The very first guide',
    guide_file: {
      io: guide_attachment,
      filename: 'lorem.pdf',
    },
    price: 1.5
  )

# Seed guides for each user
user.guides.create(
  [
    {
      title: 'Guide with no description',
      guide_file: guide_template.guide_file.blob,
    },
    {
      title: 'Guide 3',
      description: 'This is the description',
      guide_file: guide_template.guide_file.blob,
    },
  ],
)
admin.guides.create(
  [
    {
      title: 'Another guide',
      description: "This one's by the admin",
      guide_file: guide_template.guide_file.blob,
    },
    {
      title: 'Another admin guide with a long description',
      description:
        'This is a long description to see what that looks like. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus.',
      guide_file: guide_template.guide_file.blob,
    },
  ],
)
devtester.guides.create(
  [
    {
      title: 'Definitely a guide',
      description: "Pretty sure it's a guide",
      guide_file: guide_template.guide_file.blob,
    },
    {
      title:
        "This is a guide with a very long title that is the max length 120 characters long, almost, but doesn't quite get there",
      description: 'This is a short description of a guide with a long title',
      guide_file: guide_template.guide_file.blob,
    },
    {
      title: 'Running out of titles',
      guide_file: guide_template.guide_file.blob,
    },
  ],
)
