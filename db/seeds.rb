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
User.create!(
  email: "dan@gmail.com",
  name: "dan",
  password: "meetles1"
)

User.create!(
  email: "julian@gmail.com",
  name: "julian",
  password: "meetles2"
)

User.create!(
  email: "tieu@gmail.com",
  name: "tieu",
  password: "meetles3"
)

User.create!(
  email: "vincent@gmail.com",
  name: "vincent",
  password: "meetles4"
)

puts "seed stations name"
url = JSON.parse(open('./app/assets/images/stations.json').read)

stations = []
url['stations'].each { |station| stations << station unless stations.include?(station)}

stations.each { |station| Station.create(name: station['romaji'], name_kanji: station['kanji']) }

puts "Seed Done, Be carefull ... !"
