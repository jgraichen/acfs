require 'spec_helper'

describe Acfs::Request::Callbacks do
  let(:callback) { lambda { |res| } }
  let(:request)  { Acfs::Request.new('fubar') }

  describe '#on_complete' do
    it 'should store a given callback' do
      request.on_complete &callback

      expect(request.callbacks).to have(1).item
      expect(request.callbacks[0]).to be == callback
    end

    it 'should store multiple callback' do
      request.on_complete { |res| "abc" }
      request.on_complete &callback

      expect(request.callbacks).to have(2).item
      expect(request.callbacks[0]).to be == callback
    end
  end

  describe '#complete!' do
    let(:response) { Acfs::Response.new(request) }

    it 'should trigger registered callbacks with given response' do
      expect(callback).to receive(:call).with(response, kind_of(Proc))

      request.on_complete &callback
      request.complete! response
    end

    it 'should trigger multiple callback in reverted insertion order' do
      check = []

      request.on_complete { |res, nxt| check << 1; nxt.call res }
      request.on_complete { |res, nxt| check << 2; nxt.call res }
      request.on_complete { |res, nxt| check << 3; nxt.call res }

      request.complete! response

      expect(check).to be == [3, 2, 1]
    end
  end
end
