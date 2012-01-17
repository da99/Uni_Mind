
class Uni_Mind

  module Recipes

  class RVM
    
    include Uni_Arch::Base
    
    
    
  end # === module RVM
  
  end # === module Recipes
end # === class Uni_Mind
__END__





task :finish_rvm_install do

    bashrc = "~/.bashrc"
    bash_profile = "~/.bash_profile"
    rvmrc = "~/.rvmrc"

    [bashrc, bash_profile].each { |file|

      data = cat_file(file)

      if data.strip[/\&\&\ +return/]
        shell.tell " FROM === http://obsforandroid.wordpress.com/2011/06/27/rvm-1-6-20/"
        raise "in #{file}: RVM won't work if you use && return. Look at RVM instructions from bash install script."
      end

    }

    data = cat_file(rvmrc)
    if data !~ %r!rvm_pretty_print!
      sh %@ echo 'export rvm_pretty_print_flag=1' >> ~/.rvmrc @
    end


    # rvm_dir = "$HOME/.rvm/scripts/rvm"
    # text = %@ [[ -s "#{rvm_dir}" ]] && source "#{rvm_dir}" @
    # on_good_run( cat_file( bashrc ) ) do |ch, stream, data|
    #   if data !~ %r!scripts\\/rvm!
    #     run %@ echo '#{text}' >> #{bashrc} @
    #   end
    # end

    if cat_file(bash_profile) !~ %r@\.\ +#{bashrc}@
      tmp = "/tmp/temp_file_#{rand(1000)}.bash"
      sh %! cp #{bash_profile} ~/bash_profile.#{Time.now.to_i}.backup !
      sh %@ echo "if [ -f #{bashrc} ]; then" >> #{tmp} @
      sh %@ echo "  . #{bashrc}" >> #{tmp} @
      sh %@ echo "fi" >> #{tmp} @
      sh %@ cat #{bash_profile} >> #{tmp} @
      sh %@ mv #{tmp} #{bash_profile} @
    end

    at_exit do
      
      msgs = []
      
      ruby_list = bash_shell('rvm list')
      
      unless ruby_list['ree-1.8.'] || ruby_list['ruby-1.8']
        msgs << "rvm install 1.8.x"
      end
      
      
      unless ruby_list['ruby-1.9']
        msgs << "rvm install 1.9.x"
        msgs << ""
        
      end
      
      unless bash_shell('rvm list default')['ruby-1.9.']
        msgs <<  "rvm use ruby-1.9.x-pxxx --default "
      end
      
      unless msgs.empty?
        msgs << "============== NOW DO THIS: ================"
        msgs << ""
        msgs << "rvm list known"

        msgs <<  ""
        
        msgs.each { |mess|
          shell.tell mess
        }
      else 
        sh "gem update"
      end
    end

end # === finish_rvm_install

