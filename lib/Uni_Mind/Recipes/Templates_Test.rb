
class Uni_Mind

  module Recipes

  module Templates_Test

    def test_create_template_dirs
      %w{ latest origin pending }.each { |dir|
        must_be_dir File.join( 'templates', server.hostname, dir )
      }
    end
    
    def test_download_as_template raw_path
      dir         = Template_Dir.new(server.hostname)
      file        = dir.file(raw_path)
      origin      = dir.dir(:origin)
      pending     = dir.dir(:pending)
      was_pending = file.in_dir?(:pending)
      
      user_action
      
      demand( origin ) { |v|
        v.must_be! :content?, f.content
      }
      
      if not was_pending
        demand( pending ) { |v|
          v.must_be! :content?, f.content
        }
      end
    end

    def test_install_templates
    end
    
  end # === module Templates_Test
  
  end # === module Recipes
end # === class Uni_Mind
