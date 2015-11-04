require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../app/controllers/users_controller.rb', __FILE__
require File.expand_path '../../arnorails.rb', __FILE__


describe "Get User" do
  it "should allow access to the user" do
    post '/user/get.json', params = {email: "admin@a.com", password: "admin"}
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include('"name":"admin"')
  end

  it "should block user access" do
  	post '/user/get.json', params = {email: "admin", password: "admin"}
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('"fail"')
  end
end