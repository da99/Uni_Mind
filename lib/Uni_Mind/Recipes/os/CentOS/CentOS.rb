

class Uni_Mind

  module CentOS
  
    def install_libcurl
        install_packages %w~
          openldap
          openldap-dev
        
          libssh2
          libssh2-devel
        
          glibc
          glibc-devel
        ~
        install_package_from_url "http://download.fedora.redhat.com/pub/fedora/linux/development/rawhide/i386/os/Packages/libcurl-7.21.7-4.fc17.i686.rpm"
        install_package_from_url "http://download.fedora.redhat.com/pub/fedora/linux/development/rawhide/i386/os/Packages/libcurl-devel-7.21.7-4.fc17.i686.rpm"
    end
  
    def install_big_couch
        install_packages %w{ 
          libicu 
          libicu-devel 

          openssl 
          openssl-devel 

          python 
          python-devel

          gcc 
          glibc-devel 
          make 
          ncurses-devel 

          js
          js-devel
        }

        install_libcurl
        install_erlang


    end # === def install_big_couch

    def install_packages *raw_names
      names = raw_names.flatten.join(' ')
      sudo "yum install #{names}"
    end

    # From: http://www.fedorafaq.org/
    def install_package_from_url url
      file_name = File.basename(url)
      ssh %! 
        curl -O #{url}
        sudo yum --nogpgcheck install #{file_name}
        rm #{file_name}
      !
    end

    def install_from_source name
      installed = !( ssh( "which #{name}" ).strip.empty? )
      if not installed
        return( yield ) if block_given?
        sudo "yum install #{name}"
      end
    end
    
  end # === module
  
end # === class
