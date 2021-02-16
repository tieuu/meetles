# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'json'
require 'open-uri'

url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=train_station&location=35.681382,139.76608399999998&radius=30000&key=AIzaSyCwIpzQNIclviTDcD_ivXtEfD4RYwcppj4"
stations = open(url).read
station_list = JSON.parse(stations)

puts "Deleting everything"
Location.destroy_all
Meetle.destroy_all
User.destroy_all
Station.destroy_all

puts "seed users"
User.create!(
  email: "dan@gmail.com",
  # username: "dan",
  password: "meetles1"
)

User.create!(
  email: "julian@gmail.com",
  # username: "julian",
  password: "meetles2"
)

User.create!(
  email: "tieu@gmail.com",
  # username: "tieu",
  password: "meetles3"
)

User.create!(
  email: "vincent@gmail.com",
  # username: "vincent",
  password: "meetles4"
)

# puts "seed stations name"
# 100.times do
#   Station.create!(
#     name: station_list['results'].each do |station|
#       station['name']
#       )
#     end
puts "seed stations name"
station_list['results'].each do |station|
  s = Station.create!(
    name: station['name']
  )
  puts s.name
end


puts "Seed Done, Be carefull ... !"
