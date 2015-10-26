require 'mqtt'
require 'uri'
require 'geocoder'
require './arnorails.rb'

# Create a hash with the connection parameters from the URL
uri = URI.parse 'mqtt://localhost:1883'
conn_opts = {
  remote_host: uri.host,
  remote_port: uri.port,
  username: uri.user,
  password: uri.password,
}

def save_location(user, latitude, longitude)
  if latitude == 0 and longitude == 0
    return "Não foi possível encontrar a localização"
  end
  
  location = Location.find_by_user_id(user.id)

  if location
    location.latitude = latitude
    location.longitude = longitude
  else
    location = Location.new(user_id: user.id, latitude: latitude, longitude: longitude)
  end
  location.save

  Geocoder.search("#{latitude},#{longitude}").first.address
end

users = User.all
users.each do |user|
  Thread.new do
    MQTT::Client.connect(conn_opts) do |c|
      # The block will be called when you messages arrive to the topic
      c.get(user.email) do |topic, message|
        puts "#{topic}: #{message}"

        params = message.split(",")
        latitude = params[0].to_f
        longitude = params[1].to_f
        oxygenation = params[2].to_f
        pulse = params[3].to_f

        Measurement.create(user_id: user.id, blood_oxygenation: oxygenation, pulse_rate: pulse)
        puts save_location(user, latitude, longitude)
      end
    end
  end
end

MQTT::Client.connect(conn_opts) do |c|
  # publish a message to the topic 'test'
  loop do
    c.publish('admin@a.com', '0,0,0,0')
    sleep 2
  end
end