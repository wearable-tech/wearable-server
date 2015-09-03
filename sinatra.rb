# myapp.rb
require 'sinatra'
require 'json'

get '/example.json' do
  content_type :json
    { key1: 'value1', key2: 'value2' }.to_json
end

get '/test' do
  # access url like localhost:4567/test?v1=1&v2=2
  f = File.new("test.txt", "w")
  f.puts("writing...")
  f.close

  "#{params} #{ params.size} #{params['v2']}"
end
