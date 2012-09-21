$: << 'lib'
require 'sinatra'
require 'roku'

before do
  @roku = Roku::Server.new('192.168.1.137')
end

get "/" do
  "<ul>" + @roku.apps.map {|name, id| "<li><img src='/icon/#{id}' />#{name}</li>"}.join + "</ul>"
end

get "/icon/:id" do
  headers "Content-type" => "image/png"
  body @roku.icon_for params[:id]
end
