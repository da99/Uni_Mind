
class Uni_Mind
  
  module Recipes

  module File_System
    

    def test_cat
      perform_user_action
    end

    def cat file
      far_file file do
        puts far.contents
      end
    end
    
    def test_far_exists? path
    end

    def far_exists? path
      far_file path do
        far.exists?
      end
    end

    def diff file1, file2
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


__END__



    def append_to_file
      local_not_in_far do

        upload_as_temp_file {

          ssh %@
          cat #{temp_file} >> #{far}
        @

        }

        yield if block_given?
      end
    end



    # attr_accessor :local, :far, :temp_file
    # def local_file raw_local
    #   orig_local = local
    #   self.local = Local_File.new(self, raw_local)
    #   yield
    #   self.local = orig_local
    # end

    # def far_file raw_far
    #   orig_far = far
    #   self.far = Far_File.new(self, raw_far)
    #   yield
    #   self.far = orig_far
    # end

    # def local_and_far_files raw_local, raw_far
    #   local_file(raw_local) {
    #     far_file(raw_far) {
    #       
    #       yield
    #       
    #     }
    #   }
    # end
    # 
    # def local_dir path
    #   o = self.local
    #   self.local = Local_Dir.new(self, path)
    #   yield
    #   self.local = o
    # end
    # 
    # def far_dir path
    #   o = self.far
    #   self.far = Far_Dir.new(self, path)
    #   yield
    #   self.far = o
    # end
