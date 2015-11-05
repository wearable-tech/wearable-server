require "mqtt"

class User < ActiveRecord::Base
  has_one :location
  has_many :measurements
  has_many :contacts
  has_many :users, source: :contact, through: :contacts

  validates :name, presence: true
  validates :password, presence: true
  validates :email, uniqueness: true

  after_create :send_to_mqtt
  
  def send_to_mqtt
    MQTT::Client.connect(connection) do |c|
      c.publish("new_connection", email)
    end
  end

  def connection
    uri = URI.parse 'mqtt://localhost:1883'
    conn_opts = {
      remote_host: uri.host,
      remote_port: uri.port,
      username: uri.user,
      password: uri.password,
    }
  end
end
