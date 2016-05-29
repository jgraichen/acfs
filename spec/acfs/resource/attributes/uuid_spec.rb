require 'spec_helper'

describe Acfs::Resource::Attributes::UUID do
  let(:type) { Acfs::Resource::Attributes::UUID.new }

  describe '#cast' do
    subject { -> { type.cast(value) } }

    context 'with nil' do
      let(:value) { nil }
      it { expect(subject.call).to eq nil }
    end

    context 'with empty string' do
      let(:value) { '' }
      it { expect(subject.call).to eq nil }
    end

    context 'with blank string' do
      let(:value) { "  \t" }
      it { expect(subject.call).to eq nil }
    end

    context 'with string UUID' do
      let(:value) { '450b7a40-94ad-11e3-baa8-0800200c9a66' }
      it { expect(subject.call).to be_a String }
      it { expect(subject.call).to eq value }
    end

    context 'with invalid string' do
      let(:value) { 'invalid string' }
      it { is_expected.to raise_error TypeError, /invalid UUID/i }
    end

    context 'with invalid UUID' do
      let(:value) { 'xxxxxxxx-yyyy-11e3-baa8-0800200c9a66' }
      it { is_expected.to raise_error TypeError, /invalid UUID/i }
    end
  end
end
