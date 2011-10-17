
class Uni_Mind
module Erlang
  
    def install_erlang
        erl_version = "R14B03"
        file_name   = erl_version.downcase
        
        if_not_directory("/opt/erlang/#{dir}") { |install_dir|
          ssh %!
            curl -O https://raw.github.com/spawngrid/kerl/master/kerl
            chmod u+x kerl
            ./kerl build #{erl_version} #{file_name}
            ./kerl install #{file_name} #{install_dir}
            . #{install_dir}/activate
          !
        }
    end
  
end # === module Erlang
end # === class Uni_Mind
