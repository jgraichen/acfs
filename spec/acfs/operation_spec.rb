require 'spec_helper'

describe ::Acfs::Operation do
  let(:operation) { described_class.new MyUser, :read, params: {id: 0} }

  context '#request' do
    subject { operation.request }
    its(:operation) { should eq operation }
  end
end
