require 'open-uri'
require 'nokogiri'
require 'json'

url = "http://travelstation.tokyo/station/kanto/kanto.htm"

html_file = open(url).read
html_doc = Nokogiri::HTML(html_file)

stations = []

tags = html_doc.xpath("//a")
tags.each do |tag|
  station = {}
  station[tag[:href].to_s] = tag.text.to_s
  stations << station
end

stations.select! { |station| station.keys[0].end_with?("htm") }
stations.reject! { |station| station.keys[0].start_with?("..") }
stations.map! do |station|
  key = station.keys[0].split("/")[2].split(".")[0]
  value = station.values[0]
  h = {}
  h[:romaji] = key
  h[:kanji] = value
  h
end

stations_list = {}
stations_list[:stations] = stations

File.open("stations.json", 'wb') do |file|
  file.write(JSON.generate(stations_list))
end
