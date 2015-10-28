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

def send_notification(email, level, message)
    for i in level..3
      MQTT::Client.connect(connection) do |c|
        puts "to_#{email}_#{i}: #{message}"
        c.publish("to_#{email}_#{i}", message)
      end
    end
end

def verify_notification(user, measurement)
  if measurement.oxygen_level > 0
    send_notification(user.email, measurement.oxygen_level,
        "O nível oxigenação do(a) #{user.name} é #{measurement.blood_oxygenation}")
  end
  if measurement.pulse_level > 0
    send_notification(user.email, measurement.pulse_level,
        "A frequência cardíaca do(a) #{user.name} é #{measurement.pulse_rate}")
  end
end

def init_subscribe(email)
  user = User.find_by_email email

  Thread.new do
    puts "Doing subscribe to #{email}"
    MQTT::Client.connect(connection) do |c|
      c.get("from_" + email) do |topic, message|
        puts "#{topic}: #{message}"

        params = message.split(",")
        latitude = params[0].to_f
        longitude = params[1].to_f
        oxygenation = params[2].to_f
        pulse = params[3].to_f

        measurement = Measurement.create(user_id: user.id, blood_oxygenation: oxygenation,
          pulse_rate: pulse)

        puts save_location(user, latitude, longitude)

        verify_notification(user, measurement)
      end
    end
  end
end

def init_connection
  MQTT::Client.connect(connection) do |c|
    c.get("new_connection") do |topic, message|
      puts "new connection to #{message}"
      init_subscribe message
    end
  end
end

init_connection
