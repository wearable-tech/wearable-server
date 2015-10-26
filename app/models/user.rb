class User < ActiveRecord::Base
  has_many :measurements
  has_many :contacts
  has_many :users, source: :contact, through: :contacts
end
