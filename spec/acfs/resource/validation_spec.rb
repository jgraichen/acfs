# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Validation do
  let(:params) { {name: 'john smith', age: 24} }
  let(:model) { MyUserWithValidations.new params }

  describe '#valid?' do
    context 'with valid attributes' do
      subject { model }

      it { is_expected.to be_valid }
    end

    context 'with invalid attributes' do
      subject { model }

      let(:params) { {name: 'invname'} }

      it { is_expected.not_to be_valid }
    end

    context 'on resource with service side errors' do
      subject(:resource) { MyUser.create(params) }

      before { Acfs::Stub.enable }

      after  { Acfs::Stub.disable }

      before do
        Acfs::Stub.resource MyUser, :create, return: {errors: {name: ['can\'t be blank']}}, raise: 422
      end

      let(:params) { {} }

      it { is_expected.not_to be_valid }

      it 'does not override errors' do
        resource.valid?
        expect(resource.errors.to_hash).to eq(name: ['can\'t be blank'])
      end
    end
  end

  describe '#errors' do
    context 'with valid attributes' do
      subject { model.errors }

      let(:params) { {name: 'john smith', age: 24} }

      before { model.valid? }

      it { is_expected.to be_empty }
    end

    context 'with invalid attributes' do
      subject(:errors) { model.errors }

      let(:params) { {name: 'john'} }

      before { model.valid? }

      it { is_expected.not_to be_empty }
      it { is_expected.to have(2).items }

      it 'contains a list of error messages' do
        expect(errors.to_hash).to eq age: ["can't be blank"], name: ['is invalid']
      end
    end

    context 'server side errors' do
      subject { resource.errors.to_hash }

      before { Acfs::Stub.enable }

      after  { Acfs::Stub.disable }

      before do
        Acfs::Stub.resource MyUser, :create,
          with: {}, return: {errors: errors}, raise: 422
      end

      let(:params)   { {} }
      let(:resource) { MyUser.create params }

      context 'with `field => [messages]` payload' do
        let(:errors) { {name: ['cannot be blank']} }

        it { is_expected.to eq(name: ['cannot be blank']) }
      end

      context 'with `field => message` payload' do
        let(:errors) { {name: 'cannot be blank'} }

        it { is_expected.to eq(name: ['cannot be blank']) }
      end

      context 'with `[messages]` payload' do
        let(:errors) { ['cannot be blank'] }

        it { is_expected.to eq(base: ['cannot be blank']) }
      end
    end
  end

  describe '#save!' do
    subject(:save) { -> { model.save! } }

    before { allow(model).to receive(:operation) }

    context 'with invalid attributes' do
      let(:params) { {name: 'john'} }

      it { expect { save.call }.to raise_error Acfs::InvalidResource }
    end

    context 'on new resource' do
      it 'validates with `create` context' do
        expect(model).to receive(:valid?).with(:create).and_call_original
        save.call
      end
    end

    context 'on changed resource' do
      before { model.loaded! }

      let(:model) { super().tap {|m| m.id = 1 } }

      it 'validates with `save` context' do
        expect(model).to receive(:valid?).with(:save).and_call_original
        save.call
      end
    end
  end
end
