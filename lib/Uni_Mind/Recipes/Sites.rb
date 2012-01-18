
class Uni_Mind
module Recipes
class Sites
    
    include Uni_Arch::Base
  
    def setup_dirs

        ssh %!
          sudo rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm`
        !
        install_packages 'yum-utils'
        install_from_source('git') 

        ssh %! 
          sudo mkdir -p /apps
          sudo chown #{server[:user]}:#{server[:user]} /apps
          sudo chmod a+r -R /apps

          mkdir -p /apps/ruby
        !

    end
    
end # === module Sites
end # === module Recipes
end # === class Uni_Mind
