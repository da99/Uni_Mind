
require File.expand_path('spec/helper')
require 'Uni_Mind'
require 'Bacon_Colored'

require 'Unified_IO'
include Unified_IO::Local::Shell::DSL

# ======== Create files and folders.
#
FOLDER = "/tmp/Uni_Mind"
shell.run "
  rm    -rf #{FOLDER}
  cp -r spec/Boxes #{FOLDER}
"
  
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

def BIN cmd
  Unified_IO::Local::Shell.new("#{FOLDER}/Mind").run "bundle exec UNI_MIND #{cmd}"
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
