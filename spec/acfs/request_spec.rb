# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Request do
  let(:url)     { 'http://api.example.org/v1/examples' }
  let(:headers) { nil }
  let(:params)  { nil }
  let(:data)    { nil }
  let(:method)  { :get }
  let(:options) { {method: method, headers: headers, params: params, data: data} }
  let(:request) { Acfs::Request.new(url, **options) }

  describe '#url' do
    it 'returns request URL' do
      expect(request.url).to eq url
    end

    context 'with parameters' do
      let(:params) { {id: 10} }

      it 'returns URL without query' do
        expect(request.url).to eq url.to_s
      end
    end
  end

  describe '#headers' do
    let(:headers) { {'Accept' => 'application/json'} }

    it 'returns request headers' do
      expect(request.headers).to eq headers
    end
  end

  describe '#method' do
    context 'when nil given' do
      let(:method) { nil }

      it 'defaults to :get' do
        expect(request.method).to eq :get
      end
    end

    it 'returns request method' do
      expect(request.method).to eq method
    end
  end

  describe '#params' do
    let(:params) { {id: 10} }

    it 'returns request headers' do
      expect(request.params).to eq params
    end
  end

  describe '#data' do
    let(:data) { {id: 10, name: 'Anon'} }

    it 'returns request data' do
      expect(request.data).to eq data
    end

    context 'with data' do
      it { expect(request).to be_data }
    end

    context 'without data' do
      let(:data) { nil }

      it { expect(request).not_to be_data }
    end
  end
end
