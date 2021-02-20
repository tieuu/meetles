require 'open-uri'
require 'nokogiri'
require 'json'

def location(station)
  url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{station}%20station&inputtype=textquery&fields=formatted_address,name,geometry&key=AIzaSyCwIpzQNIclviTDcD_ivXtEfD4RYwcppj4"

  html_file = open(url).read
  html_doc = JSON.parse(html_file)

  location = html_doc['candidates'].first['geometry']['location']
  return "#{location['lat']},#{location['lng']}"
end

def restaurant(station)
  url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location(station)}&radius=1500&type=restaurant&key=AIzaSyCwIpzQNIclviTDcD_ivXtEfD4RYwcppj4"

  html_file = open(url).read
  html_doc = JSON.parse(html_file)

  restaurants = []
  html_doc['results'].first(3).each { |result| restaurants << result['name'] }
  return restaurants
end

puts restaurant('meguro')
