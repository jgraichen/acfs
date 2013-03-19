require 'spec_helper'

describe Acfs::Client do

  it "should have a base_url configuration option" do
    Acfs::Client.base_url = 'http://abc.de/api/v1'

    expect(Acfs::Client.base_url).to eq('http://abc.de/api/v1')
  end

end
