require 'open-uri'
require 'nokogiri'
require 'json'

class ResultStation < ApplicationRecord
  belongs_to :station
  belongs_to :meetle
  has_many :fares

  # fetch lat/long from a station name
  def self.geoloc(station)
    url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{station}%20station&inputtype=textquery&fields=formatted_address,name,geometry&key=#{ENV['GOOGLE_API']}"

    html_file = open(url).read
    html_doc = JSON.parse(html_file)

    location = html_doc['candidates'].first['geometry']['location']
    return [location['lat'], location['lng']]
  end

  # fetch near by activities
  def self.fetch_activity(station, activity = "restaurant")
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{geoloc(station)[0]},#{geoloc(station)[1]}&radius=1500&type=#{activity}&key=#{ENV['GOOGLE_API']}"

    html_file = open(url).read
    html_doc = JSON.parse(html_file)

    restaurants = []
    html_doc['results'].first(3).each { |result| restaurants << result['name'] }
    return restaurants
  end

  def self.find_circumcenter(pt1, pt2, pt3)
    # Line Pt1Pt2 is represented as ax + by = c
    a, b, c = line_from_points(pt1, pt2)
    # Line Pt2Pt3 is represented as ex + fy = g
    e, f, g = line_from_points(pt2, pt3)
    # Converting lines Pt1Pt2 and Pt2Pt3 to perpendicular
    # vbisectors. After this, L = ax + by = c
    # M = ex + fy = g
    a, b, c = perpendicular_bisector_from_line(pt1, pt2, a, b)
    e, f, g = perpendicular_bisector_from_line(pt2, pt3, e, f)
    # The point of intersection of L and M gives
    # the circumcenter
    circumcenter = two_line_intersection(a, b, c, e, f, g)
    return circumcenter[0], circumcenter[1] unless circumcenter == "parallel"
  end

  private

  ## circumcenter calculation
  # calcultate vectors
  def line_from_points(pt1, pt2)
    a = pt2[1] - pt1[1]
    b = pt1[0] - pt2[0]
    c = a * (pt1[0]) + b * (pt1[1])
    return a, b, c
  end

  def perpendicular_bisector_from_line(x, y, a, b)
    mid_point = [(x[0] + y[0]) / 2, (x[1] + y[1]) / 2]
    # c = -bx + ay
    c = -b * (mid_point[0]) + a * (mid_point[1])
    temp = a
    a = -b
    b = temp
    return a, b, c
  end

  # perpendicular lines intersection point calculation
  def two_line_intersection(a1, b1, c1, a2, b2, c2)
    determinant = a1 * b2 - a2 * b1
    # if lines are parallel.
    return "parallel" if determinant.zero?

    x = (b2 * c1 - b1 * c2) / determinant
    y = (a1 * c2 - a2 * c1) / determinant
    return [x, y]
  end
end

def self.fetch_station_code(_kanji_name)
  from_stations = ["有楽町", "目黒", "西台"]
  base_url = "https://api.ekispert.jp/v1/json/"
  station_endpoint = "station/light?"
  key = "key=#{ENV['EKISPERT_KEY']}"
  return from_stations.map do |station|
    sta_name = "name=#{CGI.escape(station)}"
    type = "type=train"
    url = "#{base_url}#{station_endpoint}#{sta_name}&#{type}&#{key}"
    json_file = JSON.parse(open(url).read)
    { name: json_file['ResultSet']['Point']['Station']['Name'],
      code: json_file['ResultSet']['Point']['Station']['code'] }
  end
end

# station name should be lower-case, with only the station name without "-" (don't the "station" or "sta.")
# 1- get station kanji name from Station Table
# 1a- get station code

base_url = "https://api.ekispert.jp/v1/json/"
geo_endpoint = "geo/station?"
radius = 2000
geopoint = "geoPoint=#{latitude},#{longitude},#{radius}"
type = "type=train"
limit = "stationCount=0"
key = "key=#{ENV['EKISPERT_KEY']}"

# get json from api
url = "#{base_url}#{geo_endpoint}#{geopoint}&#{limit}&#{type}&#{key}"
json_file = JSON.parse(open(url).read)

stations = []
json_file['ResultSet']['Point'].each do |station|
  stations << { name: station['Station']['Name'], code: station['Station']['code'] }
end

# stations = STATIONS.map do |station|
#   station = station.downcase.split[0].split("-").join.gsub("ō", "o")
#   Station.where(name: station)[0].name_kanji
# end

# 2- get route from the 3 start station to one of the station in the list (use viaList=code_from:code_to)
# 3- get fares (cheapest fee, duration) and (fee, smallest duration)
# 3a- store somewhere
# repeat 2・3 for allstations in list

save_fees = {}

from_stations.each do |from_sta|
  stations.each do |goal_sta|
    # build url
    first_sta_code = from_sta[:code]
    second_sta_code = goal_sta[:code]

    base_url = "https://api.ekispert.jp/v1/json/"
    route_endpoint = "search/course/extreme?"
    via_list = "viaList=#{first_sta_code}:#{second_sta_code}"
    key = "key=#{ENV['EKISPERT_KEY']}"

    # get json from api
    url = "#{base_url}#{route_endpoint}#{via_list}&#{key}"
    json_file = JSON.parse(open(url).read)

    # get the fees >> ResultSet/Course[0]/Price/kind=Faresummary/
    fee = nil
    json_file['ResultSet']['Course'].each do |course|
      price = course['Price'].select { |h| h['kind'] == 'FareSummary' }
      p price
      price = price.first['Oneway'].to_i
      fee = price if fee.nil? || (price < fee)
      p fee
    end

    save_fees[goal_sta[:name]] = {} if save_fees[goal_sta[:name]].nil?
    save_fees[goal_sta[:name]][from_sta[:name]] = fee
    # puts "#{goal_sta[:name]} - #{from_sta[:name]} - #{fee}"
  end
end

result = save_fees.sort_by { |_k, v| v.values.max - v.values.min }[0..2]

p result
