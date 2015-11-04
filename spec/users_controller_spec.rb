require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../app/controllers/users_controller.rb', __FILE__
require File.expand_path '../../arnorails.rb', __FILE__


describe "Get User" do
  it "should allow access to the user" do
    post '/user/get.json', params = {email: "admin@a.com", password: "admin"}
    expect(last_response.status).to eq(200)
  end
end