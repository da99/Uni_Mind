
require File.expand_path('spec/helper')
require 'Uni_Mind'
require 'Bacon_Colored'
require 'pry'
require 'Unified_IO'
Unified_IO::Local::Shell.quiet

# ======== Create files and folders.
#
FOLDER = "/tmp/Uni_Mind"
  
require 'open3'

class Box
  include Unified_IO::Local::Shell::DSL

  def chdir
    Dir.chdir("#{FOLDER}/Mind") { yield }
  end

  def mkdir f
    dir = File.join( FOLDER, f )
    shell.run "mkdir -p #{dir}"
    if block_given?
      yield dir
      shell.run "rm -r #{dir}" if File.exists?(dir)
    end
    
    f
  end

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
end # === class Box

class Remote_Box
  include Unified_IO::Remote::Shell::DSL
  include Unified_IO::Local::Shell::DSL

  def initialize
    self.server = Unified_IO::Remote::Server.new('hostname'=>'Vagrant', 'user'=>'vagrant')
  end

  def reset
    d = Unified::Remote::Dir.new("/apps")
    if d.exists?
      d.dirs.each { |path|
        ignore_exits("userdel -r #{File.basename(path)}", 6=>"does not exist")
      }
    end
    
    ssh_run("sudo rm -rf /apps")
  end

end # === Remote_Box

BOX = Box.new
BOX.reset
  

# ======== Setup helper methods.
#
def glob pattern
  Dir.glob(File.join FOLDER, pattern)
end

def chdir 
  Dir.chdir("#{FOLDER}/Mind") { yield }
end

def rmfile file
  r = chdir {
    `rm #{file}`
    yield file
  }
  BOX.reset
  r
end

def ruby_e cmd
  file = "#{FOLDER}/Mind/delete_me_perf_#{rand(100000)}.rb"

  File.open(file, 'w') { |io|
    io.write %~
    require 'Uni_Mind'
    #{cmd}
    ~
  }

  data = ''
  Open3.popen3("cd #{FOLDER}/Mind && bundle exec ruby #{file}") { |i, o, e, t|
    data << o.read
    data << e.read
  }
  data.strip
end

def BIN cmd, pre = ''
  # results = `sudo -u $USER -i sh -c "cd #{FOLDER}/Mind && #{pre} bundle exec UNI_MIND #{cmd} 2>&1"`
  results = ''
  chdir {
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

HOSTNAMES = %w~
  s1 
  s2 
  bdrm
  appster_defaults 
  bdrm 
  all_defaults 
  db1 
  no_hostname
~.sort

def exists? file
  File.exists?(File.join FOLDER, file)
end


# ======== Include the tests.
if ARGV.size > 1 && ARGV[1, ARGV.size - 1].detect { |a| File.exists?(a) }
  # Do nothing. Bacon grabs the file.
else
  Dir.glob('spec/tests/*.rb').each { |file|
    require File.expand_path(file.sub('.rb', '')) if File.file?(file)
  }
end
