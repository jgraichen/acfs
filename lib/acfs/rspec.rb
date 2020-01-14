# frozen_string_literal: true

require 'acfs'

RSpec.configure do |config|
  config.before(:each) do
    Acfs::Stub.enable
  end

  config.after(:each) do
    Acfs.reset
  end
end
