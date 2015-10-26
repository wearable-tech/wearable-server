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

users = User.all
users.each do |user|
  puts "Therad: #{user.email}"
  Thread.new do
    MQTT::Client.connect(conn_opts) do |c|
      # The block will be called when you messages arrive to the topic
      c.get(user.email) do |topic, message|
        puts "#{topic}: #{message}"

        params = message.split(",")
        print params
        latitude = params[0].to_f
        longitude = params[1].to_f
        oxygenation = params[2].to_f
        pulse = params[3].to_f

        Measurement.create(user_id: user.id, blood_oxygenation: oxygenation, pulse_rate: pulse)
      end
    end
  end
end

Thread.new do
  MQTT::Client.connect(conn_opts) do |c|
    # The block will be called when you messages arrive to the topic
    c.get('test') do |topic, message|
      puts "#{topic}: #{message}"
    end
  end
end

Thread.new do
  MQTT::Client.connect(conn_opts) do |c|
    # The block will be called when you messages arrive to the topic
    c.get('location') do |topic, message|
      if(message != "0.0,0.0")
        puts "***************************************"
        puts "location: " + message
        first_result = Geocoder.search(message).first
        puts first_result.address
        puts "***************************************"
      else
        puts "A localização foi Indefinida"
      end
    end
  end
end

MQTT::Client.connect(conn_opts) do |c|
  # publish a message to the topic 'test'
  loop do
    c.publish('test', '12,-23,21.2,80')
    sleep 10
  end
end