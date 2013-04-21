require 'spec_helper'

describe Acfs::Model::Loadable do
  let(:model) { MyUser.find 1 }
  before do
    stub_request(:get, "http://users.example.org/users/1").to_return(
        body: MessagePack.dump({ id: 1, name: "Anon", age: 12 }),
        headers: {'Content-Type' => 'application/x-msgpack'})
  end

  describe '#loaded?' do
    context 'before Acfs#run' do
      it { expect(model).to_not be_loaded }
    end

    context 'afer Acfs#run' do
      before { model; Acfs.run}
      it { expect(model).to be_loaded }
    end
  end
end
