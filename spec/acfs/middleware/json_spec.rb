# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Middleware::JSON do
  let(:data)     { [{id: 1, name: 'Anon'}, {id: 2, name: 'John', friends: [1]}] }
  let(:body)     { '' }
  let(:headers)  { {} }
  let(:request)  { Acfs::Request.new 'url', method: 'GET', data: data }
  let(:response) { Acfs::Response.new request, status: 200, headers: headers, body: body }
  let(:decoder)  { Acfs::Middleware::JSON.new ->(req) { req } }

  before do
    decoder.call request
  end

  describe 'encode' do
    context 'with not serialized request' do
      it 'should set Content-Type' do
        expect(request.headers['Content-Type']).to eq 'application/json'
      end

      it 'should append Accept header' do
        expect(request.headers['Accept']).to eq 'application/json;q=1'
      end

      it 'should serialize data to JSON' do
        expect(JSON.parse(request.body)).to eq data.map(&:stringify_keys)
      end
    end

    context 'with #to_json objects' do
      let(:data) do
        Class.new do
          def to_json(*)
            '{"a": 1, "b": 2}'
          end
        end.new
      end

      it 'should serialize data with #to_json' do
        expect(JSON.parse(request.body)).to eq 'a' => 1, 'b' => 2
      end
    end
  end

  describe 'decode' do
    context 'with JSON response' do
      let(:headers) { {'Content-Type' => 'application/json; charset=utf-8'} }
      let(:body)    { data.to_json }

      it 'should decode body data' do
        request.complete! response

        expect(response.data).to be == data.map(&:stringify_keys)
      end
    end

    context 'with invalid JSON response' do
      let(:headers) { {'Content-Type' => 'application/json'} }
      let(:body)    { data.to_json[4..-4] }

      it 'should raise an error' do
        expect { request.complete! response }.to raise_error(::JSON::ParserError)
      end
    end

    context 'without JSON response' do
      let(:headers) { {'Content-Type' => 'application/text'} }
      let(:body)    { data.to_json }

      it 'should not decode non-JSON encoded responses' do
        request.complete! response

        expect(response.data).to be_nil
      end
    end
  end
end
