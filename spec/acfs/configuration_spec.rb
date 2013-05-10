require 'spec_helper'

describe Acfs::Configuration do

  before { @configuration = Acfs::Configuration.current.dup }
  after { Acfs::Configuration.set @configuration }

  describe 'Acfs.configure' do

    it 'should invoke configure on current configuration' do
      Acfs::Configuration.current.should_receive(:configure).once.and_call_original

      Acfs.configure do |c|
        expect(c).to be_a Acfs::Configuration
      end
    end
  end
end
