# frozen_string_literal: true

require 'spec_helper'

class TestMiddleware < Acfs::Middleware::Base
end

describe Acfs::Service::Middleware do
  let(:srv_class) { Class.new(Acfs::Service) }
  let(:options) { {} }
  let(:middleware) { TestMiddleware }

  describe '.use' do
    let(:options) { {abc: 'cde'} }

    it 'adds middleware to list' do
      srv_class.use middleware

      expect(srv_class.middleware).to include(middleware)
    end

    it 'adds middleware to stack' do
      srv_class.use middleware

      expect(srv_class.middleware.build(1)).to be_a(middleware)
    end

    it 'instantiates middleware object' do
      expect(middleware).to receive(:new).with(anything, options)

      srv_class.use middleware, options
      srv_class.middleware.build
    end
  end
end
