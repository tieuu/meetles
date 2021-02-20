require 'open-uri'
require 'nokogiri'
require 'json'

class ResultStation < ApplicationRecord
  belongs_to :station
  belongs_to :meetle
  has_many :fares

  def self.location(station)
    url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{station}%20station&inputtype=textquery&fields=formatted_address,name,geometry&key=AIzaSyBu2D8KUhm_GSOBr5B9EA7ftRRfh6gGvUQ"

    html_file = open(url).read
    html_doc = JSON.parse(html_file)

    location = html_doc['candidates'].first['geometry']['location']
    return "#{location['lat']},#{location['lng']}"
  end

  def self.restaurant(station)
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location(station)}&radius=1500&type=restaurant&key=AIzaSyBu2D8KUhm_GSOBr5B9EA7ftRRfh6gGvUQ"

    html_file = open(url).read
    html_doc = JSON.parse(html_file)

    restaurants = []
    html_doc['results'].first(3).each { |result| restaurants << result['name'] }
    return restaurants
  end
end
