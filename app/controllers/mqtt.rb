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
        c.publish("to_#{email}_#{i}", message)
      end
    end
end

def build_notification(user, measurement, location)
  level = 0

  if measurement.oxygen_level > 0 or measurement.pulse_level > 0
    values = []
    values << measurement.oxygen_level if measurement.oxygen_level > 0
    values << measurement.pulse_level if measurement.pulse_level > 0
    level = values.min
  end

  message = "Valores para #{user.name}:\n\n"

  message += "Oxigenação Sanguínea "
  message += (measurement.oxygen_level > 0 ? "com problemas " : "regular ")
  message += "valor: #{measurement.blood_oxygenation}\n\n"

  message += "Frequência Cardíaca "
  message += (measurement.pulse_level > 0 ? "com problemas " : "regular ")
  message += "valor: #{measurement.pulse_rate}\n\n"

  date = measurement.created_at.strftime("%d/%m/%Y - %H:%M")
  message += "#{location}\n#{date}"

  puts "Result Message:\n#{message}"
  if level > 0
    send_notification user.email, level, message
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

        location = save_location(user, latitude, longitude)

        build_notification(user, measurement, location)
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

def init_server
  puts "Init server..."
  Thread.new do
    sleep 5
    users = User.all

    users.each do |user|
      MQTT::Client.connect(connection) do |c|
        c.publish("new_connection", user.email)
      end
    end
  end
end

init_server
init_connection
