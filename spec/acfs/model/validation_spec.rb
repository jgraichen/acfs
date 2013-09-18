require 'spec_helper'

describe Acfs::Model::Validation do
  let(:params) { {name: 'john smith', age: 24} }
  let(:model) { MyUserWithValidations.new params }

  describe '#valid?' do
    context 'with valid attributes' do
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
    subject { -> { model.save! } }
    before { model.stub(:operation) }

    context 'with invalid attributes' do
      let(:params) { {name: 'john'} }

      it { expect { subject.call }.to raise_error Acfs::InvalidResource }
    end

    context 'on new resource' do
      it 'should validate with `create` context' do
        expect(model).to receive(:valid?).with(:create).and_call_original
        subject.call
      end
    end

    context 'on changed resource' do
      let(:model) { super().tap { |m| m.id = 1 } }

      it 'should validate with `save` context' do
        expect(model).to receive(:valid?).with(:save).and_call_original
        subject.call
      end
    end
  end

  describe 'validates with context' do

  end
end
