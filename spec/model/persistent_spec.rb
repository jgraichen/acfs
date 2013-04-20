require 'spec_helper'

describe Acfs::Model::Persistent do
  let(:model) { MyUser.new }
  before do
    stub_request(:get, "http://users.example.org/users/1").to_return(
        body: MessagePack.dump({ id: 1, name: "Anon", age: 12 }),
        headers: {'Content-Type' => 'application/x-msgpack'})
  end

  context 'new model' do
    let(:user) { MyUser.new }

    it { expect(user).to_not be_persisted }
    it { expect(user).to be_new }

    context 'after save' do
      let(:user) { MyUser.new }
      before { user.save }

      it { expect(user).to be_persisted }
      it { expect(user).to_not be_new }
    end
  end

  context 'loaded model' do
    context 'without changes' do
      let(:user) { MyUser.find 1 }
      before { user; Acfs.run }

      it { expect(user).to be_persisted }
      it { expect(user).to_not be_new }
    end

    context 'with changes' do
      let(:user) { MyUser.find 1 }
      before { user; Acfs.run; user.name = "dhh" }

      it { expect(user).to_not be_persisted }
      it { expect(user).to_not be_new }
    end
  end
end
