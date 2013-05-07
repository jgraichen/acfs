require 'spec_helper'

class TestMiddleware < Acfs::Middleware::Base
end

describe Acfs::Service::Middleware do
  let(:srv_class) { Class.new(Acfs::Service) }
  let(:options) { {} }
  let(:service) { srv_class.new options }
  let(:middleware) { TestMiddleware }

  describe '.use' do
    let(:options) { { abc: 'cde' } }

    it 'should add middleware to list' do
      srv_class.use middleware

      expect(srv_class.instance_variable_get(:@middlewares)).to include(middleware)
    end

    it 'should add middleware to stack' do
      srv_class.use middleware

      expect(srv_class.middleware).to be_a(middleware)
    end

    it 'should instantiate middleware object' do
      middleware.should_receive(:new).with(anything, options)

      srv_class.use middleware, options
    end
  end

  describe '.clear' do
    before { srv_class.use middleware }

    it 'should clear middleware list' do
      srv_class.clear

      expect(srv_class.instance_variable_get(:@middlewares)).to be_empty
    end

    it 'should reset middleware stack' do
      srv_class.clear

      expect(srv_class.instance_variable_get(:@middleware)).to be_nil
    end
  end
end
