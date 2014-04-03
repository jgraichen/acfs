require 'spec_helper'

describe Acfs::Resource::Dirty do
  let(:model) { MyUser.new }
  before do
    stub_request(:get, 'http://users.example.org/users/1')
      .to_return response id: 1, name: 'Anon', age: 12
    stub_request(:post, 'http://users.example.org/users')
      .to_return response id: 5, name: 'dhh', age: 12
  end

  it 'includes ActiveModel::Dirty' do
    model.is_a? ActiveModel::Dirty
  end

  describe '#changed?' do
    context 'after attribute change' do
      let(:user) { MyUser.new name: 'dhh' }

      it { expect(user).to be_changed }

      context 'and saving' do
        before { user.save }
        it { expect(user).to_not be_changed }
      end
    end

    context 'after model load' do
      let(:user) { MyUser.find 1 }
      before { user && Acfs.run }

      it { expect(user).to_not be_changed }
    end

    context 'after model new without attrs' do
      let(:user) { MyUser.new }

      it { expect(user).to_not be_changed }
    end

    context 'after model new with attrs' do
      let(:user) { MyUser.new name: 'Uschi' }

      it { expect(user).to be_changed }
    end
  end
end
