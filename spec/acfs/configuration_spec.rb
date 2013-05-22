require 'spec_helper'

describe Acfs::Configuration do

  let(:cfg) { Acfs::Configuration.new }
  before { @configuration = Acfs::Configuration.current.dup }
  after { Acfs::Configuration.set @configuration }

  describe 'Acfs.configure' do
    it 'should invoke configure on current configuration' do
      Acfs::Configuration.current.should_receive(:configure).once.and_call_original

      Acfs.configure do |c|
        expect(c).to be_a Acfs::Configuration
      end
    end
  end

  describe '.load' do
    it 'should be able to load YAML' do
      cfg.configure do
        load 'spec/fixtures/config.yml'
      end

      expect(cfg.locate(UserService).to_s).to be == 'http://localhost:3001/'
      expect(cfg.locate(CommentService).to_s).to be == 'http://localhost:3002/'
    end

    context 'with RACK_ENV' do
      before { @env = ENV['RACK_ENV']; ENV['RACK_ENV'] = 'production' }
      after  { ENV['RACK_ENV'] = @env }

      it 'should load ENV block' do
        cfg.configure do
          load 'spec/fixtures/config.yml'
        end

        expect(cfg.locate(UserService).to_s).to be == 'http://user.example.org/'
        expect(cfg.locate(CommentService).to_s).to be == 'http://comment.example.org/'
      end
    end
  end
end
