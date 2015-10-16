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
    return "fail"
  end

  user.password == params["password"] ? "user found" : "fail"
end

post '/user/add_contact' do
  begin
    user = User.find params["id"]
  rescue
    return "fail"
  end

  begin
    user_contact = User.find_by_email params["email"]
    Contact.create level: params["level"], user_id: user.id, contact_id: user_contact.id
    "contact created"
  rescue
    "fail"
  end
end
