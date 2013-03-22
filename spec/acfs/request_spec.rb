require 'spec_helper'

describe Acfs::Request do
  let(:url)     { 'http://api.example.org/v1/examples' }
  let(:headers) { nil }
  let(:params)  { nil }
  let(:body)    { nil }
  let(:options) { {headers: headers, params: params, body: body} }
  let(:request) { Acfs::Request.new(url, options) }

  describe '#url' do
    it 'should return request URL' do
      expect(request.url).to be == url
    end
  end

  describe '#headers' do
    let(:headers) { { 'Accept' => 'application/json' } }

    it 'should return request headers' do
      expect(request.headers).to be == headers
    end
  end
end
