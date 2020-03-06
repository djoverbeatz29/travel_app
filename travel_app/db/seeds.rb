# Write your code here
require 'open-uri'
require 'net/http'
require 'json'

url = "https://pkgstore.datahub.io/core/world-cities/world-cities_json/data/5b3dd46ad10990bca47b04b4739a02ba/world-cities_json.json"
uri = URI.parse(url)
body = Net::HTTP.get_response(uri).body
data = JSON.parse(body)

data.each { |loc| Destination.create(loc) }