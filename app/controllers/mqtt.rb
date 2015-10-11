require 'mqtt'
require 'uri'
require 'geocoder'

# Create a hash with the connection parameters from the URL
uri = URI.parse 'mqtt://localhost:1883'
conn_opts = {
  remote_host: uri.host,
  remote_port: uri.port,
  username: uri.user,
  password: uri.password,
}

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
        puts "A localização foi 0.0,0.0"
      end
    end
  end
end

MQTT::Client.connect(conn_opts) do |c|
  # publish a message to the topic 'test'
  loop do
    c.publish('test', 'Hello World')
    sleep 10
  end
end