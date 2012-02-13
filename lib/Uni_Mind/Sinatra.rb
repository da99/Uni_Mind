
class Uni_Mind
  module Arch
    
    def sinatra action, *args
      public_send :"sinatra_#{action}", *args
    end # === sinatra

    def sinatra_create_app name
        shell_run "mkdir -p #{name}/public"
        files = {}
        files["config.ru"] = %~
          ruby "./#{name}"
          run #{name}
        ~
        
        files["#{name}.rb"] = %~
          require 'sinatra/base'

          class #{name} < Sinatra::Base
            get( '/' ) do
              "hi"
            end
          end
        ~
        
        files['.gitignore'] = %~
          tmp/*
          logs/*
        ~.split("\n").map(&:strip).join("\n")
        
        files["Gemfile"] = %~
          source :rubygems

          gem 'sinatra'
          gem 'passenger'
        ~
        
        files.each do |k,v|
          path = File.expand_path "#{name}/#{k}"
          next if File.exists?(path)
          File.open(path, 'w') { |io|
            io.write v
          }
        end

        Dir.chdir("#{name}") {
          unless File.expand_path(".")[/^\/tmp/]
            shell_run "bundle install"
          end
          
          shell_run "git init && git add . && git commit -m \"First commit: Uni_Mind generated code.\""
        }
        
    end
    
  end # === Arch
end # === Uni_Mind
