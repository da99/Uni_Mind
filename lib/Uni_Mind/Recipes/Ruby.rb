
class Uni_Mind
  module Recipes

  module Ruby

  def update_ruby
    raise "Not allowed as root." if root_login?
    
    ssh %@
      gem update --system
      gem update
      gem install bundler
    @
  end


    def install_ruby
        install_from_source 'ruby-build' do
          ssh %!
            git clone git://github.com/sstephenson/ruby-build.git
            cd ruby-build
            sudo ./install.sh 

            cd /apps
            git clone git://github.com/sstephenson/rbenv.git .rbenv
          ! 
        end

        if_file_is_missing " ~/.bashrc ", '/.rbenv' do |file, sub|
          ssh %!
            echo 'export PATH="/apps/.rbenv/bin:/apps/.rbenv/shims:$PATH"' >> #{file}
          ! 
        end

        if_not_directory "/apps/.rbenv/versions/1.9.2-p290" do |ruby_dir|
          ssh %!
            ruby-build 1.9.2-p290 #{ruby_dir}
          !
        end

        if_not_directory "~/.rbenv" do |dir|
          ssh %! ln -s /apps/.rbenv #{dir} !
        end

        ssh %!
          rbenv rehash
          rbenv global 1.9.2-p290
          gem update --system
          gem update
          rbenv rehash
        !



    end

end # === module Ruby
  end # === module Recipes
end # === class Uni_Mind
