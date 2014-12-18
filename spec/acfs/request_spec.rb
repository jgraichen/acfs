require 'spec_helper'

describe Acfs::Request do
  let(:url)     { 'http://api.example.org/v1/examples' }
  let(:headers) { nil }
  let(:params)  { nil }
  let(:data)    { nil }
  let(:method)  { :get }
  let(:options) { {method: method, headers: headers, params: params, data: data} }
  let(:request) { Acfs::Request.new(url, options) }

  describe '#url' do
    it 'should return request URL' do
      expect(request.url).to be == url
    end

    context 'with parameters' do
      let(:params) { {id: 10} }

      it 'should return URL without query' do
        expect(request.url).to be == "#{url}"
      end
    end
  end

  describe '#headers' do
    let(:headers) { {'Accept' => 'application/json'} }

    it 'should return request headers' do
      expect(request.headers).to be == headers
    end
  end

  describe '#method' do
    context 'when nil given' do
      let(:method) { nil }

      it 'should default to :get' do
        expect(request.method).to be == :get
      end
    end

    it 'should return request method' do
      expect(request.method).to be == method
    end
  end

  describe '#params' do
    let(:params) { {id: 10} }

    it 'should return request headers' do
      expect(request.params).to be == params
    end
  end

  describe '#data' do
    let(:data) { {id: 10, name: 'Anon'} }

    it 'should return request data' do
      expect(request.data).to be == data
    end
  end

  describe '#data' do
    context 'with data' do
      let(:data) { {id: 10, name: 'Anon'} }

      it { expect(request).to be_data }
    end

    context 'without data' do
      let(:data) { nil }

      it { expect(request).to_not be_data }
    end
  end
end
