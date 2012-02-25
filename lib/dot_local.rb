require 'singleton'
require 'yaml'
require 'pathname'
require 'dot_local/configuration'
require 'dot_local/mapper' 

module DotLocal
  class ParsingError < Exception ; end
  class MissingFile < Exception ; end
  class KeyNotFound < Exception ; end
  class DoubleLoad < Exception ; end
  class ReservedKey < Exception ; end
  class BlankValue < Exception ; end

  class << self
    def env
      @env ||= (defined?(Rails) ? Rails.env : nil)
    end

    def env=(env)
      @env = env
    end

    def deep_merge!(winner, looser)
      merger = proc do |key,winner,looser|
        if Hash === winner && Hash === looser
          winner.merge(looser, &merger)
        else
          winner.to_s == '' ? looser : winner
        end
      end

      winner.merge!(looser, &merger)
      winner
    end

  end
      
end
