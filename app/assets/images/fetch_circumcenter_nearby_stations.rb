require 'open-uri'
require 'nokogiri'
require 'json'
require 'cgi'

def location(station)
  url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=#{station}%20station&inputtype=textquery&fields=name,geometry&key=#{ENV['GOOGLE_API']}"

  html_file = open(url).read
  html_doc = JSON.parse(html_file)

  location = html_doc['candidates'].first['geometry']['location']
  return [location['lat'], location['lng']]
end

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

def two_line_intersection(a1, b1, c1, a2, b2, c2)
  determinant = a1 * b2 - a2 * b1
  # The lines are parallel.
  return "parallel" if determinant.zero?

  x = (b2 * c1 - b1 * c2) / determinant
  y = (a1 * c2 - a2 * c1) / determinant
  return [x, y]
end

def find_circumcenter(pt1, pt2, pt3)
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

  if circumcenter == "parallel"
    puts "parallel"
  else
    return circumcenter[0], circumcenter[1]
  end
end

a = location("yurakucho")
b = location("meguro")
c = location("nishidai")

ox, oy = find_circumcenter(a, b, c)

url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{ox},#{oy}&radius=5000&type=shopping_mall&fields=name&key=#{ENV['GOOGLE_API']}"

html_file = open(url).read
html_doc = JSON.parse(html_file)

places = []
html_doc['results'].first(3).each { |result| places << result['name'] }

stations = []
places.each do |place|
  place_location = location(CGI.escape(place))
  ["train", "subway"].each do |type|
    jaysonfile = JSON.parse(open("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{place_location[0]},#{place_location[1]}&radius=5000&type=#{type}_station&fields=name&key=#{ENV['GOOGLE_API']}").read)
    jaysonfile['results'].each { |result| stations << result['name'] unless stations.include?(result['name']) }
  end
end

puts stations
