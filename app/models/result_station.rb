require 'open-uri'
require 'nokogiri'
require 'json'

class ResultStation < ApplicationRecord
  belongs_to :station
  belongs_to :meetle
  has_many :fares, dependent: :destroy

  # fetch lat/long from a station name
  def self.geoloc(station)
    kanji_name = station.name_kanji
    base_url = "https://api.ekispert.jp/v1/json/"
    station_endpoint = "station?"
    key = "key=#{ENV['EKISPERT_KEY']}"
    sta_name = "name=#{CGI.escape(kanji_name)}"
    type = "type=train"
    url = "#{base_url}#{station_endpoint}#{sta_name}&#{type}&#{key}"
    json_file = JSON.parse(open(url).read)
    if json_file['ResultSet']['Point'].instance_of?(Hash)
      lat = json_file['ResultSet']['Point']['GeoPoint']['lati_d']
      long = json_file['ResultSet']['Point']['GeoPoint']['longi_d']
    else
      lat = json_file['ResultSet']['Point'].first['GeoPoint']['lati_d']
      long = json_file['ResultSet']['Point'].first['GeoPoint']['longi_d']
    end
    return [lat, long]
  end

  # fetch near by activities
  def self.fetch_activity(station, activity = "restaurant")
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{geoloc(station)[0]},#{geoloc(station)[1]}&radius=1500&keyword=#{activity}&key=#{ENV['GOOGLE_API']}"

    html_file = open(url).read
    html_doc = JSON.parse(html_file)

    places = []
    html_doc['results'].first(3).each { |result| places << result['name'] }
    return places
  end

  def self.get_three_fairest_stations(from_stations)
    if from_stations.size >= 3
      fees_hash = get_fees_from_circumcenter_stations(from_stations)
      return nil if fees_hash.nil?

      fees_hash.sort_by { |_k, v| v.values.max - v.values.min && v.values.min }[0..2]
    end
  end

  def self.find_circumcenter(stations)
    pt1 = [stations[0].latitude, stations[0].longitude]
    pt2 = [stations[1].latitude, stations[1].longitude]
    pt3 = [stations[2].latitude, stations[2].longitude]
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
    return circumcenter unless circumcenter == "parallel"
  end
  # return location(circumcenter) lat,long

  ## circumcenter calculation
  # calcultate vectors
  def self.line_from_points(pt1, pt2)
    a = pt2[1] - pt1[1]
    b = pt1[0] - pt2[0]
    c = a * (pt1[0]) + b * (pt1[1])
    return a, b, c
  end

  def self.perpendicular_bisector_from_line(x, y, a, b)
    mid_point = [(x[0] + y[0]) / 2, (x[1] + y[1]) / 2]
    # c = -bx + ay
    c = -b * (mid_point[0]) + a * (mid_point[1])
    temp = a
    a = -b
    b = temp
    return a, b, c
  end

  # perpendicular lines intersection point calculation
  def self.two_line_intersection(a1, b1, c1, a2, b2, c2)
    determinant = a1 * b2 - a2 * b1
    # if lines are parallel.
    return "parallel" if determinant.zero?

    x = (b2 * c1 - b1 * c2) / determinant
    y = (a1 * c2 - a2 * c1) / determinant
    return [x, y]
  end

  def self.get_stations_arround_circumcenter(stations)
    center_loc = find_circumcenter(stations)
    return nil if center_loc.nil?

    base_url = "https://api.ekispert.jp/v1/json/"
    geo_endpoint = "geo/station?"
    radius = 5000
    geopoint = "geoPoint=#{center_loc[0]},#{center_loc[1]},#{radius}"
    type = "type=train"
    limit = "stationCount=0"
    key = "key=#{ENV['EKISPERT_KEY']}"
    url = "#{base_url}#{geo_endpoint}#{geopoint}&#{limit}&#{type}&#{key}"
    json_file = JSON.parse(open(url).read)
    stations = []
    json_file['ResultSet']['Point'].each do |station|
      code = station.instance_of?(Hash) ? station['Station']['code'] : station[1]['code']
      stations << Station.find_by(code: code)
    end
    return stations
  end

  def self.get_fees_from_circumcenter_stations(from_stations)
    save_fees = {}
    goal_stations = get_stations_arround_circumcenter(from_stations)
    return nil if goal_stations.nil?

    from_stations.each do |from_sta|
      goal_stations.each do |goal_sta|
        next if from_sta == goal_sta

        base_url = "https://api.ekispert.jp/v1/json/"
        route_endpoint = "search/course/extreme?"
        via_list = "viaList=#{from_sta[:code]}:#{goal_sta[:code]}"
        key = "key=#{ENV['EKISPERT_KEY']}"
        url = "#{base_url}#{route_endpoint}#{via_list}&#{key}"
        json_file = JSON.parse(open(url).read)
        fee = nil
        if json_file['ResultSet']['Course'].instance_of?(Hash)
          next unless json_file['ResultSet']['Course'].keys.include?("Price")

          price = json_file['ResultSet']['Course']['Price'].select { |h| h['kind'] == 'FareSummary' }
          fee = price.first['Oneway'].to_i
        else
          json_file['ResultSet']['Course'].each do |course|
            next unless course.keys.include?("Price")

            price = course['Price'].select { |h| h['kind'] == 'FareSummary' }
            price = price.first['Oneway'].to_i
            fee = price if fee.nil? || (price < fee)
          end
        end
        unless fee.nil?
          save_fees[goal_sta] = {} if save_fees[goal_sta].nil?
          save_fees[goal_sta][from_sta] = fee
        end
      end
    end
    return save_fees
  end
end
