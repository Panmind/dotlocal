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
  end
      
end
