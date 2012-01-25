require 'spec_helper'
require './lib/configurator'

describe Configurator::Mapper do
  let(:config_hash) do
    {:foo => {:bar => {:baz => 10 } } } 
  end

  before do 
    Configurator.stub(:raw).and_return(config_hash)
  end

  it 'should return config value' do
    mapper = Configurator::Mapper.new(:foo, :bar)
    mapper.baz.should == 10 
  end
  
  it 'should return a mapper' do 
    mapper = Configurator::Mapper.new(:foo)
    mapper.bar.should be_a(Configurator::Mapper)
  end

end

describe Configurator do
  it 'should set the path where to find the config file' do
    Configurator.path = '/path/to/me'
    Configurator.path.to_s.should  == '/path/to/me'
  end

  it 'should find for a file named settings.yml' do
    Configurator.path = File.join(File.dirname(__FILE__), 'support', 'fixtures')
    Configurator.load!
  end

  it 'should raise an exception if settings file is not found' do
    Configurator.path = File.join('/path/to/nowhere')
    expect {
      Configurator.load!
    }.to raise_error(Configurator::MissingFile)
  end

  it 'should set the env' do
    Configurator.env = 'production'
    Configurator.env.should == 'production'
  end

  context 'with a settings.yml file' do
    before do
      Configurator.path = File.join(File.dirname(__FILE__), 'support', 'fixtures')
      Configurator.load!
    end
    it 'should return the raw settings hash' do
      Configurator.raw.should be_a(Hash)
    end

    it 'should create methods for top level keys' do
      Configurator.development.should be_a(Configurator::Mapper)
    end

    it 'should set env' do 
      Configurator.env = 'development' 
      Configurator.load!
      expect {
        Configurator.development
      }.to raise_error(Configurator::KeyNotFound)
    end
  end

  context 'with a settings file with errors' do
    before do
      Configurator.path = File.join(File.dirname(__FILE__), 'support', 'fixtures')
      Configurator.file_name = 'error_settings.yml'
    end
    it 'should raise ParsingError' do
      expect {
        Configurator.load!
      }.to raise_error(Configurator::ParsingError)
    end
  end
end
