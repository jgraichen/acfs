require 'spec_helper'

describe Acfs::Service do
  let(:srv_class) { Class.new(Acfs::Service) { identity :test } }
  let(:options) { {} }
  let(:service) { srv_class.new options }

  before do
    Acfs::Configuration.current.locate :test, ''
  end

  describe '#initialize' do
    let(:options) { { path: 'abc', key: 'value' } }

    it 'should set options' do
      expect(service.options).to eq(options)
    end
  end

  describe '#location' do
    let(:resource) { Class.new }
    before { allow(resource).to receive(:location_default_path, &proc{|a, p| p}) }

    it 'should extract resource path name from given class' do
      expect(service.location(resource).to_s).to eq('/classes')
    end

    context 'with path options' do
      let(:options) { { path: 'abc' } }

      it 'should have custom resource path' do
        expect(service.location(resource).to_s).to eq('/abc')
      end
    end
  end

  describe '.base_url' do

    before do
      Acfs::Configuration.current.locate :test, 'http://abc.de/api/v1'
    end

    it 'should return configured URI for service' do

      expect(srv_class.base_url).to eq('http://abc.de/api/v1')
    end
  end
end
