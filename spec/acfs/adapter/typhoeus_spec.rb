# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Adapter::Typhoeus do
  let(:adapter) { described_class.new }

  before do
    stub_request(:any, 'http://example.org').to_return status: 200
  end

  it 'raises an error' do
    request1 = Acfs::Request.new 'http://example.org' do |_rsp|
      raise '404-1'
    end
    request2 = Acfs::Request.new 'http://example.org' do |_rsp|
      raise '404-2'
    end
    adapter.queue request1
    adapter.queue request2

    expect { adapter.start }.to raise_error(/404-[12]/)
    expect { adapter.start }.not_to raise_error
  end

  it 'raises timeout' do
    stub_request(:any, 'http://example.org').to_timeout

    request = Acfs::Request.new 'http://example.org'
    adapter.queue request

    expect { adapter.run(request) }.to raise_error(Acfs::TimeoutError) do |err|
      expect(err.message).to eq 'Timeout reached: GET http://example.org'
    end
  end

  it 'raises connection errors' do
    WebMock.allow_net_connect!

    request = Acfs::Request.new 'http://should-never-exists.example.org'
    adapter.queue request

    expect { adapter.run(request) }.to raise_error(Acfs::RequestError) do |err|
      expect(err.message).to eq 'Couldn\'t resolve host name: GET http://should-never-exists.example.org'
    end
  end

  it 'passes arguments to typhoeus hydra' do
    value = {key: 1, key2: 2}

    expect(Typhoeus::Hydra).to receive(:new).with(value)

    described_class.new(**value).send :hydra
  end
end
