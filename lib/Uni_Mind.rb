require "Uni_Mind/version"
require 'Uni_Arch'
require 'Checked'
require 'Unified_IO'

require 'Uni_Mind/Template_Dir'
require 'Uni_Mind/Template_File'




class Uni_Mind
  
  Server_Not_Found = Class.new(RuntimeError)
  Wrong_IP = Class.new(RuntimeError)
  Retry_Command = Class.new(RuntimeError)
  
  include Uni_Arch::Base
  include Checked::Demand::DSL
  include Checked::Clean::DSL
  include Unified_IO::Local::Shell::DSL
  include Unified_IO::Remote::SSH::DSL
  
  # Dir.glob("#{File.dirname __FILE__}/Uni_Mind/Recipes/*.rb").map { |raw_file|
  #   name = clean(raw_file, :ruby_name)
  #   require "Uni_Mind/Recipes/#{name}"
  # }
  # =====================================================

  before
  def grab_uni_arch_files
    %w{ groups servers }.each { |cat|
      Dir.glob("configs/#{cat}/*/uni_arch.rb").each { |file|
        require File.expand_path(file)
      }
    }
  end

  before
  def set_group_or_servers
    name = request.path.split('/')[1]
    name = '*' if name == 'ALL'
    return unless name
    
    if Unified_IO::Remote::Server.server?(name)
      request.env.create :server, Unified_IO::Remote::Server.new( server_name )
      return true
    end
    

    if Unified_IO::Remote::Server.group?(name) || name == '*'
      group = Unified_IO::Remote::Server_Group.new(name)

      request.env.create :servers, group.servers
      request.env.create :group, group
      return true
    end
      
  end
  
  route "/ALL/!w action!/!* splat!/"
  def to_all_servers
    server_count = 0

    servers.each { |s|

      mind = Uni_Mind.new( request.path.sub('/ALL/', "/#{s.name}/") )
      begin
        mind.fulfill_request
        server_count += 1
      rescue Uni_Arch::No_Route_Found
      end
      
    }

    if server_count.zero?
      raise Server_Not_Found, request.path.inspect
    end
  end
  
  on_error Timeout::Error
  def puts_timeout
    if request.env.has_key?(:server)
      raise request.error, request.env.server.inspect
    end
  end
  
  on_error Net::SSH::HostKeyMismatch
  def notify_rsa_key
    e = request.error
    
    if e.message[%r!fingerprint .+ does not match for!]
      remove_rsa_host_key
      raise Uni_Mind::Retry_Command, "Removed the RSA key."
    end
  end

  after
  def disconnet
    ssh!.disconnect
  end # === def setup

  module Base

    def ssh_connect
      ssh
    end

    def ssh
      @ssh_valid ||= begin
                       ssh!.connect(server)
                       true
                     end
      super
    end

    def save_pending_templates

      if Dir.exists?('.git') && %x! git status ![/ \+configs\/servers\/.+\/templates\/pending/]
        puts %x! 
          git reset
          git add configs/servers/*/templates/*
          git commit -m "Backed up files from server."
        !.strip.split("\n").join(' && ')
      end

    end
    
    def servers
      request.env.servers
    end

    def group
      request.env.server_group
    end

  end # === module Base
  
  include Base
  
end # === class Uni_Mind


