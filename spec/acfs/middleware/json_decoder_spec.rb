require 'spec_helper'

describe Acfs::Middleware::JsonDecoder do
  let(:data)     { [{id: 1, name: "Anon"},{id: 2, name:"John", friends: [ 1 ]}] }
  let(:body)     { data.to_param }
  let(:headers)  { {} }
  let(:request)  { Acfs::Request.new "fubar" }
  let(:response) { Acfs::Response.new request, status: 200, headers: headers, body: body }
  let(:decoder)  { Acfs::Middleware::JsonDecoder.new lambda { |req| req } }

  before do
    decoder.call request
  end

  context 'with JSON response' do
    let(:headers) { { 'Content-Type' => 'application/json; charset=utf-8' } }
    let(:body)    { data.to_json }

    it 'should decode body data' do
      request.complete! response

      expect(response.data).to be == data.map(&:stringify_keys)
    end
  end

  context 'with invalid JSON response' do
    let(:headers) { { 'Content-Type' => 'application/json' } }
    let(:body)    { data.to_json[4..-4] }

    it 'should raise an error' do
      expect { request.complete! response }.to raise_error(MultiJson::LoadError)
    end
  end

  context 'without JSON response' do
    let(:headers) { { 'Content-Type' => 'application/text' } }
    let(:body)    { data.to_json }

    it 'should not decode non-JSON encoded responses' do
      request.complete! response

      expect(response.data).to be_nil
    end
  end
end
