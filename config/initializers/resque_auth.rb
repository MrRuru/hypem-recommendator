require 'resque/server'

Resque::Server.use(Rack::Auth::Basic) do |user, password|  
  (user == ENV['ADMIN_LOGIN']) && 
  (password == ENV['ADMIN_PASSWORD'])
end