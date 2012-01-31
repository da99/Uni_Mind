class Uni_Mind
  class Apps
    
    def initialize
      @array = Dir.glob("apps/*/config/thin*.yml").map { |y|
        App.new(y)
      }
      
      orig_ports = @array.map(&:ports).flatten
      ports = orig_ports.uniq
      count = ports.map { |prt| orig_ports.select { |o| o == prt }.size }
      dups  = ports.zip(count).select { |pair| pair.last > 1 }.map(&:first)

      dup_apps = @array.select { |a| !( (a.ports & dups).empty? ) }
      
      raise App::Duplicate_Port, "#{dups.inspect} in #{dup_apps.map(&:file_name).inspect}" unless dups.empty?
    end
    
    def to_a
      @array
    end
    
    def to_mustache
      @array.map(&:to_mustache)
    end

  end # === class Apps
end # === class Uni_Mind
