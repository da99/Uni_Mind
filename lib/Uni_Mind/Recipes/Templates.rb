
class Uni_Mind
  class Recipes
    class Templates < Sinatra::Base

      include Uni_Mind::Arch

      get "/:server_name/upload_templates/"
      def upload_templates
        ssh_connect
        templates.sync
      end

      private # ====================================================

      def templates
        @templates ||= Template_Dir.new(server.hostname)
      end

      public # =====================================================

      def create_template_dirs
        templates.addrs.each { |d|
          shell "mkdir -p #{d}"
        }

      %w{ latest origins pending }.each { |dir|
        must_be_dir File.join( 'templates', server.hostname, dir )
      }
      end

      def download_as_template far_path
        tmpl = templates.file(far_path)
        tmpl.download

        raw_path = request.path

        dir         = Template_Dir.new(server.hostname)
        file        = dir.file(raw_path)
        origins     = dir.dir(:origins)
        pending     = dir.dir(:pending)
        was_pending = file.in_dir?(:pending)

        user_action

        string!( origins ).be! [ :content?, f.content ]

        if not was_pending
          string!( pending ).be! [ :content?, f.content ]
        end
      end

      def install_templates

        templates.upload


        # # 
        # # Get all .pac(new|save|old) files.
        # # 
        # # Loop .pac files:
        # #   NEXT If file does not exist.
        # #   NEXT If files have been downloaded.
        # #   
        # #   Download .pac file.
        # #   yell at user: Unknown .pac file found.
        # #   abort
        # #     
        # files = ssh(%!egrep "pac(new|orig|save)" /var/log/pacman.log!).split.uniq
        # files.each { |file|
        #   far_file(file) { 
        #     next if !far_file_exists?
        #     next if far_is_in_origin?
        #     far_must_be_in_origins
        #   }
        # }
      end

      def remove_pac_file
        raise "Not implemented."

        # 
        # Check if .pac file exists on server.
        # 
        # Get target local dir.
        # Check if .pac file exists locally.
        # Check if template file exists.
        # 
        # if local_dir AND .pac exists AND template file exists
        #   remotely: trash the file (ie don't delete).
        #
      end

      # visudo manual: http://www.sudo.ws/sudo/sudoers.man.html
      def download_as_templates 

        hash = Hash[
        '/etc/ssh/sshd_config' => 'sshd_config.sh',
        '/etc/sudoers'         => 'visudo.txt',
        '~/.bashrc'            => 'bashrc.sh',
        '~/.bash_profile'      => 'bash_profile.sh',
        '~/.bash_logout'       => 'bash_logout.sh'
        ]

        do_commit = false



        hash.each { | far, raw_local|

          local = "templates/#{raw_local}"
          shell %! touch #{local} !

          original = File.read(local)
          content = ssh %! sudo cat #{far} !

          if original.strip.split != content.strip.split
            File.open( local, 'w') do |io|
              io.write content
            end

            do_commit = true
          end

        } # === hash.each

        if do_commit
          shell( %~
            git reset
            git add templates/*
            git commit -m "Updated template files."
          ~) 
        end

      end # === def download_to_templates

    end # === class Templates
  end # === class Recipes
end # === class Uni_Mind
