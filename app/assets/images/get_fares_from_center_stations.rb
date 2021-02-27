require 'open-uri'
require 'json'

latitude = 35.70966888192536
longitude = 139.69125122597706

from_stations = ["有楽町", "目黒", "西台"]
base_url = "https://api.ekispert.jp/v1/json/"
station_endpoint = "station/light?"
key = "key=#{ENV['EKISPERT_KEY']}"
from_stations = from_stations.map do |station|
  sta_name = "name=#{CGI.escape(station)}"
  type = "type=train"
  url = "#{base_url}#{station_endpoint}#{sta_name}&#{type}&#{key}"
  json_file = JSON.parse(open(url).read)
  { name: json_file['ResultSet']['Point']['Station']['Name'],
    code: json_file['ResultSet']['Point']['Station']['code'] }
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
# 4- compare fees and keep fairest ones and store station in Result_station Table with fares in Fare Table
# 4- or compare durations and keep fairest ones //
