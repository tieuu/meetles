require 'json'
require 'open-uri'
url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=train_station&location=35.681382,139.76608399999998&radius=30000&key=AIzaSyCwIpzQNIclviTDcD_ivXtEfD4RYwcppj4"
stations = open(url).read
station_list = JSON.parse(stations)
puts station_list
