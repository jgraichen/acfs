require 'spec_helper'

class TestMiddleware < Acfs::Middleware::Base
end

describe Acfs::Service::Middleware do
  let(:srv_class) { Class.new(Acfs::Service) }
  let(:options) { {} }
  let(:middleware) { TestMiddleware }

  describe '.use' do
    let(:options) { {abc: 'cde'} }

    it 'should add middleware to list' do
      srv_class.use middleware

      expect(srv_class.middleware).to include(middleware)
    end

    it 'should add middleware to stack' do
      srv_class.use middleware

      expect(srv_class.middleware.build(1)).to be_a(middleware)
    end

    it 'should instantiate middleware object' do
      expect(middleware).to receive(:new).with(anything, options)

      srv_class.use middleware, options
      srv_class.middleware.build
    end
  end
end
