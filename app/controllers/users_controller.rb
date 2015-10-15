require 'sinatra'
require './arnorails.rb'

post '/user/save' do
  User.create email: params["email"], password: params["password"]
  "user created"
end

post '/user/get' do
  begin
    user = User.find_by_email params["email"]
  rescue
    return "user not found"
  end

  user.password == params["password"] ? "user found" : "user not found"
end

post '/user/add_contact' do
  begin
    user = User.find params["id"]
  rescue
    return "user not found"
  end

  begin
    user_contact = User.find_by_email params["email"]
    Contact.create level: params["level"], user_id: user.id, contact_id: user_contact.id
    "contact created"
  rescue
    "contact not found"
  end
end
