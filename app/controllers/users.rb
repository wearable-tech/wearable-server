require 'sinatra'
require '../../arnorails.rb'

post '/user/save' do
  User.create(email: params["email"], password: params["password"])
end