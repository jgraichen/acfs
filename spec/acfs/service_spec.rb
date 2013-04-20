require 'spec_helper'

describe Acfs::Service do
  let(:srv_class) { Class.new(Acfs::Service) }
  let(:options) { {} }
  let(:service) { srv_class.new options }

  describe '#initialize' do
    let(:options) { { path: 'abc', key: 'value' } }

    it "should set options" do
      expect(service.options).to eq(options)
    end
  end

  describe '#url_for' do
    it 'should extract resource path name from given class' do
      expect(service.url_for(Class)).to eq('/classes')
    end

    context 'with path options' do
      let(:options) { { path: 'abc' } }

      it 'should have custom resource path' do
        expect(service.url_for(Class)).to eq('/abc')
      end
    end
  end

  describe '.base_url' do
    it "should have a static base_url configuration option" do
      srv_class.base_url = 'http://abc.de/api/v1'

      expect(srv_class.base_url).to eq('http://abc.de/api/v1')
    end
  end
end
