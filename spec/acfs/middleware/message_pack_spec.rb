# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Middleware::MessagePack do
  let(:data)     { [{id: 1, name: 'Anon'}, {id: 2, name: 'John', friends: [1]}] }
  let(:body)     { '' }
  let(:headers)  { {} }
  let(:request)  { Acfs::Request.new 'url', data: data }
  let(:response) { Acfs::Response.new request, status: 200, headers: headers, body: body }
  let(:decoder)  { Acfs::Middleware::MessagePack.new ->(req) { req } }

  before do
    decoder.call request
  end

  describe 'encode' do
    context 'with not serialized request' do
      it 'sets Content-Type' do
        expect(request.headers['Content-Type']).to eq 'application/x-msgpack'
      end

      it 'appends Accept header' do
        expect(request.headers['Accept']).to eq 'application/x-msgpack;q=1'
      end

      context 'with JSON chained' do
        let(:decoder) { Acfs::Middleware::JSON.new super(), q: 0.5 }

        it 'appends to Accept header' do
          expect(request.headers['Accept']).to eq 'application/json;q=0.5,application/x-msgpack;q=1'
        end
      end

      it 'serializes data to MessagePack' do
        expect(MessagePack.unpack(request.body)).to eq data.map(&:stringify_keys)
      end
    end
  end

  context 'with Message Pack response' do
    let(:headers) { {'Content-Type' => 'application/x-msgpack'} }
    let(:body)    { MessagePack.pack data }

    it 'decodes body data' do
      request.complete! response

      expect(response.data).to be == data.map(&:stringify_keys)
    end
  end

  context 'without Message Pack response' do
    let(:headers) { {'Content-Type' => 'application/text'} }
    let(:body)    { data.to_json }

    it 'does not decode non-MessagePack encoded responses' do
      request.complete! response

      expect(response.data).to be_nil
    end
  end
end
