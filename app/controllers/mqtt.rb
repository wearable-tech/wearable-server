require 'mqtt'
require 'uri'
require 'geocoder'
require './arnorails.rb'

def connection
  uri = URI.parse 'mqtt://localhost:1883'
  conn_opts = {
    remote_host: uri.host,
    remote_port: uri.port,
    username: uri.user,
    password: uri.password,
  }
end

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

def init_subscribe(email)
  user = User.find_by_email email

  Thread.new do
    puts "Doing subscribe to #{email}"
    MQTT::Client.connect(connection) do |c|
      c.get(email) do |topic, message|
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

def init_connection
  Thread.new do
    MQTT::Client.connect(connection) do |c|
      c.get("new_connection") do |topic, message|
        puts "new connection to #{message}"
        init_subscribe message
      end
    end
  end
end

def do_publish
  MQTT::Client.connect(connection) do |c|
    loop do
      puts "Doing publish to admin@a.com"
      c.publish('admin@a.com', '0,0,0,0')
      sleep 5
    end
  end
end

init_connection
do_publish
