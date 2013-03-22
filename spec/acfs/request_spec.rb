require 'spec_helper'

describe Acfs::Request do
  let(:url)     { 'http://api.example.org/v1/examples' }
  let(:headers) { nil }
  let(:params)  { nil }
  let(:data)    { nil }
  let(:options) { {headers: headers, params: params, data: data} }
  let(:request) { Acfs::Request.new(url, options) }

  describe '#url' do
    it 'should return request URL' do
      expect(request.url).to be == url
    end

    context 'with parameters' do
      let(:params) { { id: 10 }}

      it 'should return URL with query' do
        expect(request.url).to be == "#{url}?id=10"
      end
    end

    context 'with parameters in URL' do
      let(:url) { 'http://api.example.org/v1/examples?b=ac' }
      let(:params) { { id: 10 }}

      it 'should strip query from URL and append params' do
        expect(request.url).to be == 'http://api.example.org/v1/examples?id=10'
      end
    end
  end

  describe '#headers' do
    let(:headers) { { 'Accept' => 'application/json' } }

    it 'should return request headers' do
      expect(request.headers).to be == headers
    end
  end

  describe '#params' do
    let(:params) { { id: 10 }}

    it 'should return request headers' do
      expect(request.params).to be == params
    end
  end
end
