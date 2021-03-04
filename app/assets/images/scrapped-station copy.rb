require 'open-uri'
require 'nokogiri'
require 'json'

# # uncomment to get stations informations from API
# base_url = "https://api.ekispert.jp/v1/json/station?type=train&key=#{ENV['EKISPERT_KEY']}"

# i = 1
# stations = []
# sta_text = []

# 21.times do
#   url = "#{base_url}&offset=#{i}"
#   json_file = JSON.parse(open(url).read)
#   json_file['ResultSet']['Point'].each do |station|
#     next unless [11, 12, 13, 14, 19].include?(station['Prefecture']['code'].to_i)

#     sta = {}
#     sta[:name_kanji] = station['Station']['Name']
#     sta[:code] = station['Station']['code'].to_i
#     sta[:latitude] = station['GeoPoint']['lati_d'].to_f
#     sta[:longitude] = station['GeoPoint']['longi_d'].to_f
#     stations << sta
#     sta_text << sta[:name_kanji]
#   end
#   i += 100
#   p i
# end

# stations_list = {}
# stations_list[:stations] = stations

# # uncomment to get all stations information
# File.open("stations.json", 'wb') do |file|
#   file.write(JSON.generate(stations_list))
# end

# # uncomment to get station name only to pass to google translate to get romaji name
# File.open('stations.txt', 'wb') do |f|
#   f.write(sta_text)
# end

txt_file = File.read('stations.txt')
json_file = JSON.parse(open('stations.json').read)

txt_file = txt_file.gsub("\\", "").gsub('"', '').gsub('[', '').gsub(']', '').gsub(/\n/, '').split(",")

stations = []

json_file["stations"].each_with_index do |station, idx|
  station[:name] = txt_file[idx]
  stations << station
end

stations_list = {}
stations_list[:stations] = stations
File.open("stations_goodone.json", 'wb') do |file|
  file.write(JSON.generate(stations_list))
end
