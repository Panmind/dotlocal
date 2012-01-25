class Configurator
  class Mapper

    def initialize(*args)
      args.map! {|n| n.to_s }

      @parents = args
      @config = Configurator.raw

      parents = @parents.dup

      while parent = parents.shift
        @config = @config.fetch(parent) 
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
      if @config.fetch(key).is_a? Hash
        @parents << key
        self.class.new(*@parents)
      else
        @config.fetch(key)
      end
    end
  end
end
