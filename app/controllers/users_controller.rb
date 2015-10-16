require 'sinatra'
require 'json'
require './arnorails.rb'

post '/user/save' do
  User.create email: params["email"], password: params["password"]
  "user created"
end

post '/user/get' do
  user = User.find_by_email params["email"]

  if user
    "user found" if user.password == params["password"]
  else
    "fail"
  end
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

post '/user/contacts.json' do
  user = User.find_by_email params["email"]

  if user
    contacts = Contact.find_all_by_user_id user.id
    content_type :json
      contacts_json = contacts.map do |c|
        email = User.find(c.contact_id).email

        {email: email, level: c.level}
      end

      contacts_json.to_json
  else
    content_type :json
      "fail".to_json
  end
end