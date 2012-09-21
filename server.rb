$: << 'lib'
require 'sinatra'
require 'roku'

before do
  @roku = Roku::Server.new('192.168.1.137')
end

get "/" do
  "<ul>" + @roku.apps.map {|name, id| "<li><a href='/launch/#{id}'><img src='#{@roku.url_for_icon id}' />#{name}</a></li>"}.join + "</ul>"
end

get '/launch/:id' do
  @roku.launch params[:id]
  redirect '/'
end

