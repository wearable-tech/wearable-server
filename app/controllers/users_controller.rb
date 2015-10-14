require 'sinatra'
require './arnorails.rb'

post '/user/save' do
  User.create email: params["email"], password: params["password"]
  "user created"
end

post '/user/get' do
  user = User.find_by_email params["email"]
  result = "fail"

  if user and user.password == params["password"]
    result = "user found"
  end

  result
end

post '/user/add_contact' do
  user = User.find params["id"]

  unless user.nil?
    user_contact = User.find_by_email params["email"]
      unless user_contact.nil?
        Contact.create level: params["level"], user_id: user.id, contact_id: user_contact.id
        "contact created"
        return
      end
  end

  "fail"
end
