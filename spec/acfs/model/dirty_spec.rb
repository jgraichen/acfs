require 'spec_helper'

describe Acfs::Model::Dirty do
  let(:model) { MyUser.new }
  before do
    stub_request(:get, "http://users.example.org/users/1").to_return(
        body: MessagePack.dump({ id: 1, name: "Anon", age: 12 }),
        headers: {'Content-Type' => 'application/x-msgpack'})
  end

  it 'includes ActiveModel::Dirty' do
    model.is_a? ActiveModel::Dirty
  end

  describe '#changed?' do
    context 'after attribute change' do
      let(:user) { MyUser.new }
      before { user.name = "dhh" }
      it { expect(user).to be_changed }

      context 'and saving' do
        before { user.save }
        it { expect(user).to_not be_changed }
      end
    end

    context 'after model load' do
      let(:user) { MyUser.find 1 }
      before { user; Acfs.run}

      it { expect(user).to_not be_changed }
    end

    context 'after model new without attrs' do
      let(:user) { MyUser.new }

      it { expect(user).to_not be_changed }
    end

    context 'after model new with attrs' do
      let(:user) { MyUser.new name: "Uschi" }

      it { expect(user).to be_changed }
    end
  end
end
