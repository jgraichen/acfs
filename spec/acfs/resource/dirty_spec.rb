require 'spec_helper'

describe Acfs::Resource::Dirty do
  let(:user) { MyUser.new }
  subject { user }

  before do
    stub_request(:get, 'http://users.example.org/users/1')
      .to_return response id: 1, name: 'Anon', age: 12
    stub_request(:post, 'http://users.example.org/users')
      .to_return response id: 5, name: 'dhh', age: 12
  end

  describe '#changed?' do
    context 'after attribute change' do
      let(:user) { MyUser.new name: 'dhh' }

      it { expect(user).to be_changed }
      it { expect(user).to be_name_changed }

      context 'and saving' do
        before { user.save }
        it { expect(user).to_not be_changed }
        it { expect(user).to_not be_name_changed }
      end
    end

    context 'after model load' do
      let(:user) { MyUser.find 1 }
      before { user && Acfs.run }

      it { expect(user).to_not be_changed }
      it { expect(user).to_not be_name_changed }
    end

    context 'after model new without attrs' do
      let(:user) { MyUser.new }

      it { expect(user).to_not be_changed }
      it { expect(user).to_not be_name_changed }
    end

    context 'after model new with attrs' do
      let(:user) { MyUser.new name: 'Uschi' }

      it { expect(user).to be_changed }
      it { expect(user).to be_name_changed }
    end

    context 'with from and to' do
      before { user.name = 'Ringo' }
      it { is_expected.to be_name_changed(from: 'Anon', to: 'Ringo') }
      it { is_expected.to be_name_changed(from: 'Anon') }
      it { is_expected.to be_name_changed(to: 'Ringo') }
      it { is_expected.to_not be_name_changed(from: nil, to: 'Ringo') }
      it { is_expected.to_not be_name_changed(from: 'Anon', to: nil) }
      it { is_expected.to_not be_name_changed(from: nil) }
      it { is_expected.to_not be_name_changed(to: nil) }
    end
  end

  describe '#changed' do
    subject { user.changed }
    it { is_expected.to eq [] }

    context 'after change' do
      before { user.name = 'Paul' }
      it { is_expected.to eq ['name'] }
    end
  end

  describe '#changes' do
    subject { user.changes }
    it { is_expected.to eq({}) }

    context 'after change' do
      before { user.name = 'Paul' }
      it { is_expected.to eq 'name' => ['Anon', 'Paul'] }

      it 'has indifferent access' do
        expect(user.changes[:name]).to eq ['Anon', 'Paul']
      end
    end
  end

  describe '#attribute_changed?' do
    let(:attr) { :name }
    subject { user.attribute_changed?(attr) }
    it { is_expected.to eq false }

    context 'after change' do
      before { user.name = 'Paul' }
      it { is_expected.to eq true }

      it 'accept strings too' do
        expect(user.attribute_changed?(attr.to_s)).to eq true
      end
    end
  end

  describe '#restore_attributes' do
    before { user.name = 'Paul' }
    subject { user.restore_attributes }

    it 'changes attribute back to old value' do
      expect { subject }.to change { user.name }.from('Paul').to('Anon')
    end
  end

  describe '#restore_name!' do
    before { user.name = 'Paul' }
    subject { user.restore_name! }

    it 'changes attribute back to old value' do
      expect { subject }.to change { user.name }.from('Paul').to('Anon')
    end
  end
end
