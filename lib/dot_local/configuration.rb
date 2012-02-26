module DotLocal
  class Configuration

    SettingsFileName = 'settings.yml'
    LocalSuffix = 'local'
    
    ReservedKeys = %w(env path file_name local_file_name raw)

    attr_accessor :env, :path, :file_name, :local_file_name, :raw

    def initialize(options={}) 
      @path = options.delete :path
      @file_name = options.delete :file_name
      @local_file_name = options.delete :local_file_name
      @env = options.delete :env

      @path = File.expand_path('..', __FILE__) if @path.nil?
      @file_name ||= SettingsFileName
      @local_file_name ||= interpolate_local_filename
    end
    
    def method_missing(*args)
      super unless args.size == 1
      key = args.first.to_s 
      if Mapper.key_is_hash?(@raw, key) 
        Mapper.new(self, key)
      else 
        Mapper.fetch(@raw, key)
      end
    end

    def reload!
      @loaded = false
      self.load!
    end

    def load!
      raise DotLocal::DoubleLoad if @loaded 
      @loaded = true
      @raw = parse(file_name)
      @parsed = @raw
      @raw = @raw.fetch(@env.to_s) unless @env.nil?

      merge_with_local! if local_exists?
      
      validate_blank_values! 
      validate_reserved_keys! 
      
      @raw.freeze
    end

    private

    def merge(first, second)

    end

    def local_exists?
      File.exists?(File.join(path, local_file_name))
    end

    def recursive_find_blank_values(key,value)
      if value.is_a?(Hash)
        value.each do |key,value| 
          recursive_find_blank_values(key,value)
        end
      else
        if value.to_s == ''
          raise BlankValue.new("Blank value found for key #{key}")
        end
      end
    end

    def validate_blank_values!
      @raw.each do |key,value|
        recursive_find_blank_values(key,value)
      end
    end

    def validate_reserved_keys!
      ReservedKeys.each do |key| 
        if @raw.keys.map(&:to_s).include? key
          raise DotLocal::ReservedKey.new("Reserved #{key} found")
        end
      end
    end

    def parse(file_name)
      file = File.read(File.join(path, file_name).to_s)
      yaml = YAML.load(file)
      raise unless yaml.is_a? Hash
      yaml

    rescue Errno::ENOENT
      raise DotLocal::MissingFile.new("File #{file} not found")
    rescue => e 
      raise ParsingError.new(e.message)
    end

    def interpolate_local_filename
      ext = File.extname(@file_name)
      "#{@file_name.gsub(ext, '')}.#{LocalSuffix}#{ext}"
    end

    def merge_with_local!
      local_hash = parse(local_file_name)
      local_hash = local_hash.fetch(@env.to_s) unless @env.nil?
      @raw = DotLocal.deep_merge!(local_hash, @raw)
    end

  end
end
