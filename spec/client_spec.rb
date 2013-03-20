require 'spec_helper'

describe Acfs::Client do
  let(:client) do
    Class.new(MyClient) do |cls|
      cls.base_url = MyClient.base_url
    end
  end

  describe '#initialize' do
    it "should use global base_url by default" do
      client.base_url = 'http://abc.de/api/v1'

      expect(client.new.base_url).to eq('http://abc.de/api/v1')
    end

    it "should allow to specify a runtime base_url" do
      client.new(base_url: 'http://abc.de/api/v1').tap do |client|
        expect(client.base_url).to eq('http://abc.de/api/v1')
      end
    end
  end

  describe '#base_url' do
    it "should have a runtime base_url configuration option" do
      client.new.tap do |client|
        client.base_url = 'http://abc.de/api/v1'

        expect(client.base_url).to eq('http://abc.de/api/v1')
      end
    end
  end

  describe '.base_url' do
    it "should have a static base_url configuration option" do
      client.base_url = 'http://abc.de/api/v1'

      expect(client.base_url).to eq('http://abc.de/api/v1')
    end
  end

end
