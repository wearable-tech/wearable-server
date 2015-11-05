require "./arnorails.rb"

User.create(name: "admin", email: "admin@a.com", password: "admin", level: 0)
User.create(name: "teste", email: "teste@a.com", password: "teste", level: 0)
User.create(name: "root", email: "root@a.com", password: "root", level: 0)
User.create(name: "usuario", email: "usuario@a.com", password: "usuario", level: 0)
Contact.create(user_id: 1, contact_id: 2, level: 1)
Contact.create(user_id: 3, contact_id: 2, level: 1)
Measurement.create(user_id: 2, blood_oxygenation: 80.0, pulse_rate: 100)
Location.create(user_id: 2, latitude: -10.0, longitude: -10.0)
