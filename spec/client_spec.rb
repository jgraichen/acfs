require 'spec_helper'

describe Acfs::Client do
  let(:client) { MyClient }

  it "should have a base_url configuration option" do
    client.base_url = 'http://abc.de/api/v1'

    expect(client.base_url).to eq('http://abc.de/api/v1')
  end

end
