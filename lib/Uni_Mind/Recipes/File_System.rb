
class Uni_Mind

  module Recipes

    class File_System

      include Uni_Arch::Base

      route "/!w/diff/!w/!w/"
      def diff
        server, file1, file2 = request.captures
        output = %x! diff #{File.expand_path file1.strip} #{File.expand_path file2.strip} !
        case $?.exitstatus
        when 0, 1
          puts output
        else
          raise "Local Error: #{output}"
        end
        
        output
      end

    end # === module 

  end # === module Recipes
end # === class Uni_Mind


