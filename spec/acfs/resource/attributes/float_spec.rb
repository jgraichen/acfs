# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Attributes::Float do
  let(:type) { Acfs::Resource::Attributes::Float.new }

  describe '#cast' do
    subject(:cast) { type.cast value }

    context 'with nil' do
      let(:value) { nil }

      it { expect(cast).to be_nil }
    end

    context 'with blank string (I)' do
      let(:value) { '' }

      it { expect(cast).to eq 0.0 }
    end

    context 'with blank string (II)' do
      let(:value) { "  \t" }

      it { expect(cast).to eq 0.0 }
    end

    context 'with float' do
      let(:value) { 1.7 }

      it { expect(cast).to eq 1.7 }
    end

    context 'with Infinity' do
      let(:value) { 'Infinity' }

      it { expect(cast).to eq Float::INFINITY }
    end

    context 'with -Infinity' do
      let(:value) { '-Infinity' }

      it { expect(cast).to eq(-Float::INFINITY) }
    end

    context 'with NaN' do
      let(:value) { 'NaN' }

      it { expect(cast).to be_nan }
    end

    context 'with fixnum' do
      let(:value) { 1 }

      it { expect(cast).to eq 1.0 }
    end

    context 'with valid string' do
      let(:value) { '1.7' }

      it { expect(cast).to eq 1.7 }
    end

    context 'with invalid string (I)' do
      let(:value) { '1.7a' }

      it { expect { cast }.to raise_error ArgumentError }
    end
  end
end
