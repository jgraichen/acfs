require 'spec_helper'

describe Acfs::Model::Validation do
  let(:params) { {} }
  let(:model) { MyUserWithValidations.new params }

  describe '#valid?' do
    context 'with valid attributes' do
      let(:params) { {name: 'john smith', age: 24} }
      subject { model }

      it { should be_valid }
    end

    context 'with invalid attributes' do
      let(:params) { {name: 'invname'} }
      subject { model }

      it { should_not be_valid }
    end
  end

  describe '#errors' do
    context 'with valid attributes' do
      let(:params) { {name: 'john smith', age: 24} }
      before { model.valid? }
      subject { model.errors }

      it { should be_empty }
    end

    context 'with invalid attributes' do
      let(:params) { {name: 'john'} }
      before { model.valid? }
      subject { model.errors }

      it { should_not be_empty }
      it { should have(2).items }

      it 'should contain a list of error messages' do
        expect(subject.to_hash).to eq age: ["can't be blank"], name: ['is invalid']
      end
    end
  end

  describe '#save!' do
    context 'with invalid attributes' do
      let(:params) { {name: 'john'} }
      subject { -> { model.save! } }

      it { expect { subject.call }.to raise_error Acfs::InvalidResource }
    end
  end
end
