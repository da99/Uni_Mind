#!/usr/bin/ruby

opts = eval(File.read("conf/servers/SERVER_01.rb"))
default_run_options[:pty] = true 
ssh_options[:keys] = [File.expand_path("~/.ssh/mu.private")]
set :user, 'da99'
role :app_server, opts[:ip]+':'+opts[:port].to_s, :primary=>true


desc "Simple test."
task :testing do
  run "sudo uptime"
  run "sudo uptimes"
end

