require 'spec_helper'

describe Acfs::Middleware::MessagePackDecoder do
  let(:data)     { [{id: 1, name: "Anon"},{id: 2, name:"John", friends: [ 1 ]}] }
  let(:body)     { data.to_param }
  let(:headers)  { {} }
  let(:request)  { Acfs::Request.new "fubar" }
  let(:response) { Acfs::Response.new request, status: 200, headers: headers, body: body }
  let(:decoder)  { Acfs::Middleware::MessagePackDecoder.new lambda { |req| req } }

  before do
    decoder.call request
  end

  context 'with Message Pack response' do
    let(:headers) { { 'Content-Type' => 'application/x-msgpack' } }
    let(:body)    { MessagePack.pack data }

    it 'should decode body data' do
      request.complete! response

      expect(response.data).to be == data.map(&:stringify_keys)
    end
  end

  context 'without Message Pack response' do
    let(:headers) { { 'Content-Type' => 'application/text' } }
    let(:body)    { data.to_json }

    it 'should not decode non-MessagePack encoded responses' do
      request.complete! response

      expect(response.data).to be_nil
    end
  end
end
