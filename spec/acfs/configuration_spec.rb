# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Configuration do
  let(:cfg) { Acfs::Configuration.new }

  around do |example|
    configuration = Acfs::Configuration.current.dup
    example.run
  ensure
    Acfs::Configuration.set(configuration)
  end

  describe 'Acfs.configure' do
    it 'invokes configure on current configuration' do
      expect(Acfs::Configuration.current).to receive(:configure).once.and_call_original

      Acfs.configure do |c|
        expect(c).to be_a Acfs::Configuration
      end
    end
  end

  describe '.load' do
    it 'is able to load YAML' do
      cfg.configure do
        load 'spec/fixtures/config.yml'
      end

      expect(cfg.locate(UserService).to_s).to eq 'http://localhost:3001/'
      expect(cfg.locate(CommentService).to_s).to eq 'http://localhost:3002/'
    end

    context 'with RACK_ENV' do
      around do |example|
        env = ENV['RACK_ENV']
        ENV['RACK_ENV'] = 'production'
        example.run
      ensure
        ENV['RACK_ENV'] = env
      end

      it 'loads ENV block' do
        cfg.configure do
          load 'spec/fixtures/config.yml'
        end

        expect(cfg.locate(UserService).to_s).to eq 'http://user.example.org/'
        expect(cfg.locate(CommentService).to_s).to eq 'http://comment.example.org/'
      end
    end
  end

  describe '#adapter' do
    let(:object) { Object.new }

    it 'is a accessor' do
      cfg.adapter = object
      expect(cfg.adapter).to eq object
    end
  end
end
