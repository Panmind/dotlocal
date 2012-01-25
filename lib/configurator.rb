require 'singleton'
require 'yaml'
require 'pathname'
# require 'configurator/configurator_mapper'

class Configurator
  include Singleton

  SettingsFileName = 'settings.yml'
  SettingsLocalFileName = 'settings.local.yml'

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

  def self.env=(env)
    @env = env
  end

  def self.env
    @env
  end

  def self.to_ary
    # rspec seems to require this
  end

  def self.method_missing(*args)
    if args.size == 1
      # Calling something like Configurator.key_one
      Mapper.new(args.first)
    else
      super
    end
  end

  def self.file_name=(file_name)
    @file_name = file_name
  end

  def self.file_name
    @file_name || SettingsFileName
  end

  def self.local_file_name=(local_file_name)
    @local_file_name || SettingsLocalFileName
  end

  def self.load!
    file = File.read(path.join(file_name).to_s)
    @raw = parse(file, env)
    @raw.freeze
    @raw

  rescue Errno::ENOENT
    raise Configurator::MissingFile
  end

  def self.path=(path)
    @path = Pathname.new(path)
  end

  def self.path
    @path
  end

  def self.raw
    @raw
  end

  private

  def self.parse(file, env=nil)
    yaml = YAML.load(file)
    yaml = yaml.fetch(env) unless env.nil?
    raise unless yaml.is_a? Hash
    yaml
  rescue
    raise ParsingError
  end

  class ParsingError < Exception ; end
  class MissingFile < Exception ; end
  class KeyNotFound < Exception ; end

end

