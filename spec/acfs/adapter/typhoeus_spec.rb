require 'spec_helper'

describe Acfs::Adapter::Typhoeus do
  let(:adapter) { described_class.new }
  before { WebMock.allow_net_connect! }

  it 'raises an error' do
    request1 = Acfs::Request.new 'http://altimos.de/404.1' do |rsp|
      raise '404-1'
    end
    request2 = Acfs::Request.new 'http://altimos.de/404.2' do |rsp|
      raise '404-2'
    end
    adapter.queue request1
    adapter.queue request2

    expect{ adapter.start }.to raise_error /404\-[12]/
    expect{ adapter.start }.to_not raise_error
  end
end
