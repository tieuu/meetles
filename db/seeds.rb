# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'json'
require 'open-uri'

puts "Deleting everything"
ResultStation.destroy_all
Location.destroy_all
Station.destroy_all
Meetle.destroy_all
User.destroy_all

puts "seed users"
avatar_dan = URI.open('https://res.cloudinary.com/deumrs4dd/image/upload/v1615018025/Meetle/Image_from_iOS_dkrghz.jpg')
user_dan =  User.create!(
  email: "dan@gmail.com",
  name: "dan",
  password: "meetles1"
)
user_dan.photo.attach(io: avatar_dan, filename: 'vincent.png', content_type: 'image/png')
user_dan.save


avatar_julian = URI.open('https://res.cloudinary.com/deumrs4dd/image/upload/v1615018025/Meetle/Image_from_iOS_1_s2qmjo.jpg')
user_julian = User.create!(
  email: "julian@gmail.com",
  name: "julian",
  password: "meetles2"
)
user_julian.photo.attach(io: avatar_julian, filename: 'vincent.png', content_type: 'image/png')
user_julian.save

avatar_tieu = URI.open('https://res.cloudinary.com/deumrs4dd/image/upload/v1615018025/Meetle/Image_from_iOS_2_i59eh7.jpg')
user_tieu = User.create!(
  email: "tieu@gmail.com",
  name: "tieu",
  password: "meetles3"
)
user_tieu.photo.attach(io: avatar_tieu, filename: 'vincent.png', content_type: 'image/png')
user_tieu.save

avatar_vincent = URI.open('https://res.cloudinary.com/deumrs4dd/image/upload/v1615018025/Meetle/Image_from_iOS_3_us7fha.jpg')
user_vincent = User.create!(
  email: "vincent@gmail.com",
  name: "vincent",
  password: "meetles4"

)
user_vincent.photo.attach(io: avatar_vincent, filename: 'vincent.png', content_type: 'image/png')
user_vincent.save
puts "seed stations name"
url = JSON.parse(open('./app/assets/images/stations.json').read)

url['stations'].each_with_index do |station, i|
  Station.create!(name: station['name'],
                  name_kanji: station['name_kanji'],
                  latitude: station['latitude'],
                  longitude: station['longitude'],
                  code: station['code'])
  puts i
end


puts "Seed Done, Be carefull ... !"
