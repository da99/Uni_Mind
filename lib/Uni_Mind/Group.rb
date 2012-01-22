

class Uni_Mind
  
  module Group
    MODS.each { |m|
      include Uni_Mind.const_get(m.to_sym)::Group
    }
    
    attr_reader :apps

    def fulfill
    return super if respond_to?(request.method_name)
      @apps ||= env.servers.map { |s| 
        a = Uni_Mind.new(s.hostname, request.method_name, request.args) 
        a.request.klass.new(self)
      }
      invalid = apps.select { |a| !a.respond_to?(request.method_name) }
      
      if invalid.empty?
        response.body apps.map(&:fulfill)
      else
        raise Uni_Arch::Not_Found, invalid.map { |i| i.request.path }.join(', ')
      end
    end

  end # === module Group
  
end # === class Uni_Mind
