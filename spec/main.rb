
require File.expand_path('spec/helper')
require 'Uni_Mind'
require 'Bacon_Colored'

require 'Unified_IO'
Unified_IO::Local::Shell.quiet

# ======== Create files and folders.
#
FOLDER = "/tmp/Uni_Mind"
  
class Box
  include Unified_IO::Local::Shell::DSL
  
  def reset
    shell.run "
      rm -rf #{FOLDER}
      cp -r  spec/Boxes #{FOLDER}
      cp Gemfile.lock #{FOLDER}/Mind/Gemfile.lock
    "
    Dir.glob("spec/Boxes/Mind/configs/servers/*/templates/*/*.txt").each { |file|
      shell.run "rm #{file}" if file['origins/'] || file['pending/']
    }
  end
end

BOX = Box.new
BOX.reset
  

# ======== Setup helper methods.
#
def glob pattern
  Dir.glob(File.join FOLDER, pattern)
end

def BIN cmd, pre = ''
  # results = `sudo -u $USER -i sh -c "cd #{FOLDER}/Mind && #{pre} bundle exec UNI_MIND #{cmd} 2>&1"`
  results = ''
  Dir.chdir("#{FOLDER}/Mind") {
    results = `#{pre} bundle exec UNI_MIND #{cmd} 2>&1`
  }
  if $?.exitstatus != 0
    raise Unified_IO::Local::Shell::Failed, results
  end
  results
end

def BIN_SKIP_IP_CHECK cmd
  BIN cmd, "SKIP_IP_CHECK=true"
end

def exists? file
  File.exists?(File.join FOLDER, file)
end


# ======== Include the tests.
#
Dir.glob('spec/tests/*.rb').each { |file|
  require File.expand_path(file.sub('.rb', '')) if File.file?(file)
}
