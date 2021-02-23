require 'open-uri'
require 'nokogiri'
require 'json'

class ResultStation < ApplicationRecord
  belongs_to :station
  belongs_to :meetle
  has_many :fares

  def self.location(station)
    url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{station}%20station&inputtype=textquery&fields=formatted_address,name,geometry&key=#{ENV['GOOGLE_API']}"

    html_file = open(url).read
    html_doc = JSON.parse(html_file)

    location = html_doc['candidates'].first['geometry']['location']
    return "#{location['lat']},#{location['lng']}"
  end

  def self.restaurant(station)
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location(station)}&radius=1500&type=restaurant&key=#{ENV['GOOGLE_API']}"

    html_file = open(url).read
    html_doc = JSON.parse(html_file)

    restaurants = []
    html_doc['results'].first(3).each { |result| restaurants << result['name'] }
    return restaurants
  end

  FAKE_RESULT_2 = {
    'yurakucho': {
      'sugamo': { fee: 200, duration: 22 },
      'sengoku': { fee: 220, duration: 15 },
      'hakusan': { fee: 220, duration: 13 }
    },
    'itabashihoncho': {
      'sugamo': { fee: 220, duration: 8 },
      'sengoku': { fee: 220, duration: 10 },
      'hakusan': { fee: 220, duration: 11 }
    }
  }

  FAKE_RESULT_3 = {
    'yurakucho': {
      'sugamo': { fee: 200, duration: 22 },
      'nakai': { fee: 350, duration: 39 },
      'akebonobashi': { fee: 280, duration: 15 }
    },
    'itabashihoncho': {
      'sugamo': { fee: 220, duration: 8 },
      'nakai': { fee: 330, duration: 50 },
      'akebonobashi': { fee: 280, duration: 26 }
    },
    'meguro': {
      'sugamo': { fee: 200, duration: 26 },
      'nakai': { fee: 320, duration: 26 },
      'akebonobashi': { fee: 280, duration: 35 }
    }
  }
end
