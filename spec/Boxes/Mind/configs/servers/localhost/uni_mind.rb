
class LOCALHOST < Sinatra::Base

  include Uni_Mind::Arch
  include Unified_IO::Local::Shell::DSL

  map '/localhost'

  get '/print_info/:prop'
  def print_info 
    puts "Server info: #{server.send(params[:prop])}"
  end
  
end # === class LOCALHOST


Uni_Mind.use LOCALHOST
  
