require 'spec_helper'
require './lib/dot_local'

describe DotLocal::Mapper do
  let(:config_hash) do
    {'foo' => {'bar' => {'baz' => 10 } } }
  end

  let(:config) do
    config = DotLocal::Configuration.new
    config.stub(:raw => config_hash)
    config
  end

  it 'should return config value' do
    mapper = DotLocal::Mapper.new(config, :foo, :bar)
    mapper.baz.should == 10
  end

  it 'should return a mapper' do
    mapper = DotLocal::Mapper.new(config, :foo)
    mapper.bar.should be_a(DotLocal::Mapper)
  end

end

describe DotLocal do
  it 'should set path by options' do
    config = DotLocal::Configuration.new(:path => '/path/to/me')
    config.path.to_s.should == '/path/to/me'
  end

  it 'should set env by options' do
    DotLocal.env = 'production'
    config = DotLocal::Configuration.new
    config.env.should == 'production'
  end

  it 'should look for a file named settings.yml' do
    path =  File.join(File.dirname(__FILE__), 'support', 'fixtures')
    config = DotLocal::Configuration.new(:path => path)
    config.load!
  end

  it 'should raise an exception if settings file is not found' do
    config = DotLocal::Configuration.new(:path => '/path/to/nowhere')
    expect {
      config.load!
    }.to raise_error(DotLocal::MissingFile)
  end

  context 'on fixtures path' do 
    let(:path) { File.join(File.dirname(__FILE__), 'support', 'fixtures') }

    context 'with a settings file' do
      let(:config) do
        DotLocal::Configuration.new(:path => path).tap do |config|
          config.load!
        end
      end

      it 'should return the raw settings hash' do
        config.raw.should be_a(Hash)
      end

      it 'should raise for double load call' do 
        expect {
          config.load! 
        }.to raise_error(DotLocal::DoubleLoad)
      end

      it 'should allow for reload' do
        expect {
          config.reload! 
        }.to_not raise_error
      end

      it 'should raise if settings has reserved keys' do
        config.file_name = 'reserved_keys.yml'
        config.env = nil
        expect {
          config.reload!
        }.to raise_error(DotLocal::ReservedKey)
      end

      it 'should create methods for top level keys' do
        DotLocal.env = nil
        config.reload!
        config.development.should be_a(DotLocal::Mapper)
      end

      it 'should set env' do
        config.env = 'development'
        config.reload!
        expect {
          config.development
        }.to raise_error(DotLocal::KeyNotFound)
      end
    end

    context 'with a settings file with errors' do
      let(:config) do
        DotLocal::Configuration.new(:path => path,
                                    :file_name => 'error_settings.yml')
      end

      it 'should raise ParsingError' do
        expect {
          config.load!
        }.to raise_error(DotLocal::ParsingError)
      end
    end

    context 'on a settings file with nil keys' do
      let(:config) do
        DotLocal::Configuration.new(:path => path,
                                    :file_name => 'blank_values.yml')
      end

      it 'should raise an exception' do 
        expect { 
          config.load! 
        }.to raise_error(DotLocal::BlankValue)
      end
    end
  end
end
