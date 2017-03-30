# ... edited by app gen (DB seeder, Rake tasks, etc...)

Product.delete_all
User.delete_all

store_owner = User.create!(
  email: "store-owner@#{Rails.application.class.parent_name.dasherize}.com",
  name: 'Store Owner',
  password: 'abcdefgh',
  password_confirmation: 'abcdefgh'
)

40.times do
  product = Product.create!(
    name: Faker::Commerce.product_name,
    user: store_owner,
    description: Faker::Company.catch_phrase,
    price: Faker::Commerce.price,
    in_stock: 10 + rand(100),
    sku: Faker::Number.number(8)
  )

  text = product.name.split(/\s+/).last
  bgcolor = format '%06x', rand(0xFFFFFF)
  alpha = format '%03d', rand(128)
  product.update(
    media: "http://fakeimg.pl/440x320/#{bgcolor},#{alpha}/?text=#{text}"
  )
end
