# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Request::Callbacks do
  let(:callback) { ->(_res) {} }
  let(:request)  { Acfs::Request.new('fubar') }

  describe '#on_complete' do
    it 'stores a given callback' do
      request.on_complete(&callback)

      expect(request.callbacks).to have(1).item
      expect(request.callbacks[0]).to eq callback
    end

    it 'stores multiple callback' do
      request.on_complete {|_res| 'abc' }
      request.on_complete(&callback)

      expect(request.callbacks).to have(2).item
      expect(request.callbacks[0]).to eq callback
    end
  end

  describe '#complete!' do
    let(:response) { Acfs::Response.new(request) }

    it 'triggers registered callbacks with given response' do
      expect(callback).to receive(:call).with(response, kind_of(Proc))

      request.on_complete(&callback)
      request.complete! response
    end

    it 'triggers multiple callback in reverted insertion order' do
      check = []

      request.on_complete do |res, nxt|
        check << 1
        nxt.call res
      end
      request.on_complete do |res, nxt|
        check << 2
        nxt.call res
      end
      request.on_complete do |res, nxt|
        check << 3
        nxt.call res
      end

      request.complete! response

      expect(check).to eq [3, 2, 1]
    end
  end
end
