require 'sinatra'
require 'json'
require './arnorails.rb'

post '/user/save' do
  user = User.new name: params["name"], email: params["email"], password: params["password"], level: 0
  if user.valid?
    user.save
    "user created"
  else
    "fail"
  end
end

post '/user/get.json' do
  user = User.find_by_email params["email"]

  if user
    if user.password == params["password"]
      content_type :json
        return [{name: user.name, email: user.email, password: user.password, level: user.level}].to_json
    end
  end

  "fail".to_json
end

post '/user/update' do
  user = User.find_by_email params["current_email"]
  print params
  user.name = params["name"]
  user.email = params["new_email"]
  user.level = params["level"]
  user.password = params["password"] if params["password"]
  user.save
  "user updated"
end

post '/user/add_contact' do
  user = User.find_by_email params["user_email"]

  if user
    user_contact = User.find_by_email params["contact_email"]

    if user_contact
      contact = Contact.find_by_user_id_and_contact_id user.id, user_contact.id

      if contact
        contact.level = params["contact_level"]
      else
        contact = Contact.new(user_id: user.id,
          contact_id: user_contact.id, level: params["contact_level"])
      end

      contact.save
      return "contact saved"
    end
  end

  "fail"
end

post '/user/contacts.json' do
  user = User.find_by_email params["email"]

  if user
    contacts = Contact.find_all_by_user_id user.id
    
    content_type :json
      contacts_json = contacts.map do |c|
        contact = User.find(c.contact_id)
        email = contact.email
        name = contact.name

        {name: name, email: email, level: c.level}
      end

      contacts_json.to_json
  else
    content_type :json
      "fail".to_json
  end
end

post '/user/define_level' do
  user = User.find_by_email params["email"]

  if user
    user.level = params["level"]
    user.save

    "level changed"
  else
    "fail"
  end
end

post '/user/delete_contact' do
  user = User.find_by_email params['user_email']
  user_contact = User.find_by_email params['contact_email']

  if user and user_contact
    contact = Contact.find_by_user_id_and_contact_id user.id, user_contact.id

    if contact
      contact.delete
      return "contact removed"
    end
  end

  "fail"
end
