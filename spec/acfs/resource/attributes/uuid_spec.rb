# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Attributes::UUID do
  let(:type) { Acfs::Resource::Attributes::UUID.new }

  describe '#cast' do
    subject(:cast) { type.cast(value) }

    context 'with nil' do
      let(:value) { nil }

      it { expect(cast).to be_nil }
    end

    context 'with empty string' do
      let(:value) { '' }

      it { expect(cast).to be_nil }
    end

    context 'with blank string' do
      let(:value) { "  \t" }

      it { expect(cast).to be_nil }
    end

    context 'with string UUID' do
      let(:value) { '450b7a40-94ad-11e3-baa8-0800200c9a66' }

      it { expect(cast).to be_a String }
      it { expect(cast).to eq value }
    end

    context 'with invalid string' do
      let(:value) { 'invalid string' }

      it { expect { cast }.to raise_error TypeError, /invalid UUID/i }
    end

    context 'with invalid UUID' do
      let(:value) { 'xxxxxxxx-yyyy-11e3-baa8-0800200c9a66' }

      it { expect { cast }.to raise_error TypeError, /invalid UUID/i }
    end
  end
end
