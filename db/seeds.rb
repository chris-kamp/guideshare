User.destroy_all
Guide.destroy_all
Tag.destroy_all

# Seed users
user1 =
  User.create(
    email: 'user1@user1.com',
    username: 'user1',
    password: "password",
    cart: Cart.new
  )
devguides =
  User.create(
    email: 'devguides@devguides.com',
    username: 'devguides',
    password: "password",
    cart: Cart.new
  )
workouts =
  User.create(
    email: 'bestworkouts@bestworkouts.com',
    username: 'BestWorkouts',
    password: "password",
    cart: Cart.new
  )
budgeting =
  User.create(
    email: 'budgeting@budgeting.com',
    username: 'personal_finance_tips42',
    password: "password",
    cart: Cart.new
  )
reader =
  User.create(
    email: 'reader@reader.com',
    username: 'reader',
    password: "password",
    cart: Cart.new
  )
anon1 =
  User.create(
    email: 'anon1@anon1.com',
    username: 'anonymous1',
    password: "password",
    cart: Cart.new
  )
anon2 =
  User.create(
    email: 'anon2@anon2.com',
    username: 'anonymous2',
    password: "password",
    cart: Cart.new
  )
anon3 =
  User.create(
    email: 'anon3@anon3.com',
    username: 'anonymous3',
    password: "password",
    cart: Cart.new
  )
anon4 =
  User.create(
    email: 'anon4@anon4.com',
    username: 'anonymous4',
    password: "password",
    cart: Cart.new
  )
anon5 =
  User.create(
    email: 'anon5@anon5.com',
    username: 'anonymous5',
    password: "password",
    cart: Cart.new
  )

# Seed tags

tags = {
  diy: Tag.create(name: "DIY"),
  tech: Tag.create(name: "Tech"),
  dev: Tag.create(name: "Software Development"),
  fitness: Tag.create(name: "Health & Fitness"),
  art: Tag.create(name: "Arts & Crafts"),
  finance: Tag.create(name: "Personal Finance"),
  cooking: Tag.create(name: "Cooking"),
  productivity: Tag.create(name: "Productivity"),
  short: Tag.create(name: "Short"),
  long: Tag.create(name: "Long"),
  beginner: Tag.create(name: "Beginner"),
  intermediate: Tag.create(name: "Intermediate"),
  expert: Tag.create(name: "Expert")
}


# To avoid excessive Cloudinary requests, when seeding, load one attachment and replicate for other seeded guides.
guide_attachment1 = File.open(File.join(Rails.root, 'app/assets/documents/lorem.pdf'))
guide_attachment2 = File.open(File.join(Rails.root, 'app/assets/documents/two-page-lorem.pdf'))

guide_template1 =
  user1.guides.create(
    title: "How to create a guide",
    description: 'The most important guide of all',
    guide_file: {
      io: guide_attachment1,
      filename: 'lorem.pdf',
    },
    tags: [tags[:tech], tags[:short], tags[:beginner]]
  )

guide_template2 =
  user1.guides.create(
    title: "GuideShare Tips and Tricks",
    description: 'Great ways to get more out of GuideShare',
    guide_file: {
      io: guide_attachment2,
      filename: 'two-page-lorem.pdf',
    },
    tags: [tags[:tech], tags[:long], tags[:intermediate]]
  )

lorem = user1.guides.create(
    title: 'What does Lorem Ipsum really mean?',
    description:
      'Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus, error odit necessitatibus magnam itaque rem voluptates fugit nesciunt? Doloribus. Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus repudiandae fuga corrupti corporis quod non voluptatibus.',
    guide_file: guide_template1.guide_file.blob,
    price: 1,
    reviews: [
      Review.create(user: anon1, rating: 5, content: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus."),
      Review.create(user: anon2, rating: 5, content: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus."),
      Review.create(user: anon3, rating: 5, content: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus."),
      Review.create(user: anon4, rating: 5, content: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus."),
      Review.create(user: anon5, rating: 5, content: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Illo, quam assumenda temporibus possimus."),
      Review.create(user: reader, rating: 0, content: "I don't get it"),
    ]
)

[anon1, anon2, anon3, anon4, anon5, reader].each { |user| user.owned_guides.push(lorem) }

workouts.guides.create(
  [
    {
      title: 'Top 10 quarantine workouts',
      description: "Stay active while staying home",
      guide_file: guide_template1.guide_file.blob,
      price: 4.95,
      tags: [tags[:fitness], tags[:productivity]]
    },
    {
      title: 'How to create a diet plan',
      guide_file: guide_template2.guide_file.blob,
      price: 4.95,
      tags: [tags[:fitness], tags[:cooking]]
    },
  ],
)
budgeting.guides.create(
  [
    {
      title: "Your first budgeting spreadsheet",
      guide_file: guide_template1.guide_file.blob,
      price: 9.95,
      tags: [tags[:finance], tags[:long]]
    },
    {
      title: 'Personal finance basics',
      description: "By following this one simple guide, you too can become a millionaire, probably",
      guide_file: guide_template2.guide_file.blob,
      price: 99.95,
      tags: [tags[:beginner], tags[:short], tags[:finance]],
      reviews: [
        Review.create(user: reader, rating: 3, content: "A bit overpriced"),
        Review.create(user: anon1, rating: 2)
      ]
    },
  ],
)

reader.owned_guides.push(budgeting.guides.last)
anon1.owned_guides.push(budgeting.guides.last)

devguides.guides.create(
  [
    {
      title: 'Understanding prototypal inheritance in JavaScript',
      description: "It's a bit complicated",
      guide_file: guide_template2.guide_file.blob,
      price: 10,
      tags: [tags[:tech], tags[:dev], tags[:expert]],
      reviews: [
        Review.create(user: reader, rating: 1, content: "I'm still confused")
      ]
    },
    {
      title: 'How to build your first Ruby on Rails app',
      description: "Get started now with one simple command",
      guide_file: guide_template1.guide_file.blob,
      tags: [tags[:tech], tags[:dev], tags[:beginner]],
      price: 2
    },
    {
      title: 'Top 10 VSCode extensions every Rails dev needs',
      guide_file: guide_template2.guide_file.blob,
      price: 5,
      tags: [tags[:tech], tags[:dev], tags[:intermediate]],
      reviews: [
        Review.create(user: reader, rating: 3, content: "Pretty helpful"),
        Review.create(user: anon1, rating: 4),
        Review.create(user: anon2, rating: 1),
      ]
    },
  ],
)

reader.owned_guides.push(devguides.guides.first)
[reader, anon1, anon2].each { |user| user.owned_guides.push(devguides.guides.last) }