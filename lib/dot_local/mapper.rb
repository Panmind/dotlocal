module DotLocal
  class Mapper

    def initialize(config, *args)
      args.map! {|n| n.to_s }

      @config = config
      @parents = args
      @raw = config.raw 

      parents = @parents.dup

      while parent = parents.shift
        @raw = @raw.fetch(parent) 
      end

    rescue KeyError
      raise KeyNotFound.new("You were looking for #{parent} but no luck")
    end

    def method_missing(*args)
      super if args.count > 1
      process(args.first.to_s)
    end

    private

    def process(key)
      if @raw.fetch(key).is_a? Hash
        @parents << key
        self.class.new(@config, *@parents)
      else
        @raw.fetch(key)
      end
    end
  end
end
