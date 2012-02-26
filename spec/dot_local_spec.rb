require 'spec_helper'
require './lib/dot_local'

describe DotLocal do
  describe 'deep_merge!' do
    let(:winner) { {:a => {:b => 'y'}, :c => nil }}
    let(:looser) { {:a => {:b => 'x', :d => 'x'}, :c => 'x'} }
    before do
      DotLocal.deep_merge!(winner,looser)
    end

    it 'should give priority if key exists' do
      winner[:a][:b].should == 'y'
    end

    it 'should keep key in nested hash' do
      winner[:a][:d].should == 'x'
    end

    it 'should keep exceeding key' do
      winner[:c].should == 'x'
    end
  end
end

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

describe DotLocal::Configuration do
  it 'should set path by options' do
    config = DotLocal::Configuration.new(:path => '/path/to/me')
    config.path.to_s.should == '/path/to/me'
  end

  it 'should set env by options' do
    config = DotLocal::Configuration.new(:env => 'production')
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

  it 'should preserve extension for local file name' do
    config = DotLocal::Configuration.new(:file_name => 'foo.yml')
    config.local_file_name.should == 'foo.local.yml'
  end

  context 'on fixtures path' do
    let(:path) { File.join(File.dirname(__FILE__), 'support', 'fixtures') }

    context 'with a settings file' do
      let(:config) do
        DotLocal::Configuration.new(:path => path).tap do |config|
          config.load!
        end
      end

      it 'should get a value without env' do
        config.env = nil
        config.reload!
        config.production.key_one.should == 1
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
        config.env = nil
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

      it 'should get a value when env is set' do
        config.env = 'development'
        config.file_name = 'settings.yml'
        config.reload!
        config.key_one.should == 11
      end

      it 'should raise when calling a missing config key' do
        expect {
          config.non_existing
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

    context 'a settings file with local' do
      let(:config) do
        DotLocal::Configuration.new(:path => path,
                                    :file_name => 'with_local.yml')
      end

      it 'should have settings overridden by local' do
        config.load!
        config.food.cheese.parmesan.should == 2
      end

    end
  end

end
