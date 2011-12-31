
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
    "
    Dir.glob("spec/Boxes/Mind/configs/servers/*/templates/*/*.txt").each { |file|
      shell.run "rm #{file}" if file['origins/'] || file['pending/']
    }
  end
end

BOX = Box.new
BOX.reset
  
# File.open("#{FOLDER}/Gemfile", 'w') { |io|
#   io.write %~
#     gem 'Uni_Mind', :path=>"#{File.expand_path('.')}"
#   ~
# }
  
# ======== Setup helper methods.
#
def glob pattern
  Dir.glob(File.join FOLDER, pattern)
end

def BIN cmd, pre = ''
  Unified_IO::Local::Shell.new("#{FOLDER}/Mind").run "#{pre} bundle exec UNI_MIND #{cmd}"
end

def BIN_SKIP_IP_CHECK cmd
  BIN cmd, "SKIP_IP_CHECK=true"
end

def exists? file
  File.exists?(File.join FOLDER, file)
end

shared "Uni_Mind" do
  before {
  }
end

# ======== Include the tests.
#
Dir.glob('spec/tests/*.rb').each { |file|
  require File.expand_path(file.sub('.rb', '')) if File.file?(file)
}
