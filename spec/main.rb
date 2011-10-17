
require File.expand_path('spec/helper')
require 'Uni_Mind'
require 'Bacon_Colored'

require 'Unified_IO'
include Unified_IO::Local::Shell::DSL

FOLDER = "/tmp/Uni_Mind"
shell.run "
  rm    -rf #{FOLDER}
  mkdir -p  #{FOLDER}
  cp -r spec/Boxes/Mind #{FOLDER}/Mind
  cp -r spec/Boxes/App1 #{FOLDER}/App1
  cp -r spec/Boxes/App2 #{FOLDER}/App2
  cp -r spec/Boxes/Db1  #{FOLDER}/Db1
"
  

Dir.glob('spec/tests/*.rb').each { |file|
  require File.expand_path(file.sub('.rb', '')) if File.file?(file)
}
