

class Uni_Mind
  
  module Group
    MODS.each { |m|
      include Uni_Mind.const_get(m.to_sym)::Group
    }
    
    attr_reader :apps
    
    def fulfill
      return super if respond_to?(request.method_name)
      @apps ||= servers.map { |s| 
        a = Uni_Mind.new(s.hostname, env.method_name, env.args) 
        a.env.klass.new(self)
      }
      invalid = apps.select { |a| !a.respond_to?(env.method_name) }
      
      if invalid.empty?
        apps.each(&:fulfill)
      else
        raise Not_Found, invalid.map { |i| i.request.path }.join(', ')
      end
    end

  end # === module Group
  
end # === class Uni_Mind
