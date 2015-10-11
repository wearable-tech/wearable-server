require 'sinatra'
require '../../arnorails.rb'

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
