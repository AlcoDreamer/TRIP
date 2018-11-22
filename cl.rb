require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("http://localhost:8080/v1/marks")

header = {'Content-Type' => 'application/json'}

data = {
  mark: {
     car_number: 'a111aa-10-aa',
     tag: 'YASYA FOREVER'
  }
}

# Create the HTTP objects
http = Net::HTTP.new(uri.host, uri.port)
req = Net::HTTP::Post.new(uri.request_uri, header)
req.body = data.to_json

# Send the request
#response = http.request(req)

http.request(req)

puts req.body