module DotLocal
  class Mapper

    def initialize(config, *args)
      @parents = args.map!(&:to_s) 
      @config  = config
      @raw     = config.raw
      parents  = @parents.dup 

      # Iterate the three and stop at the last 
      # key. @raw is now the last member of
      # the chain. 
      # This means that @raw can be either a Hash or 
      # a value
      while parent = parents.shift
        @raw = Mapper.fetch(@raw, parent)
      end
    end

    def method_missing(*args)
      super if args.count > 1
      return_value_or_mapper(args.first.to_s)
    end

    def self.fetch(hash, key)
      hash.fetch(key) 
    rescue KeyError
      raise KeyNotFound.new("You were looking for #{key} but no luck")
    end

    def to_hash
      @raw if @raw.is_a?(Hash)
    end

    private
    
    def return_value_or_mapper(key)
      if return_mapper?(@raw, key)
        @parents << key
        self.class.new(@config, *@parents)
      else
        self.class.fetch(@raw, key)
      end
    end

    def return_mapper?(value, key)
      value.is_a?(Hash) && self.class.key_is_hash?(value, key) 
    end

    def self.key_is_hash?(value, key)
      value.fetch(key).is_a?(Hash)
    rescue KeyError
      false
    end

  end
end
