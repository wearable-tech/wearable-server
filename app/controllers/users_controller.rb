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
  user = User.find_by_email params['email_user']
  contact = User.find_by_email params['email_contact']
  id = Contact.find_by_sql["SELECT id FROM contacts WHERE user_id = ? AND contact_id = ?", user.id, contact.id]
  con = Contact.find(id)
  if con
    con[0].delete
    "contact removed"
  else
    "fail"
  end
end

post '/user/delete_contact' do
  user = User.find_by_email params['email_user']
  contact = User.find_by_email params['email_contact']
  user.id.to_s + " " + contact.id.to_s
  id = Contact.find_by_sql ["SELECT id FROM contacts WHERE user_id = ? AND contact_id = ?", user.id, contact.id]
  con = Contact.find(id)
  if con
    con[0].delete
    "contact removed"
  else
    "fail"
  end
end
