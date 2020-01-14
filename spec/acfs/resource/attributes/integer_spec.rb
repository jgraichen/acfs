# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Attributes::Integer do
  let(:type) { Acfs::Resource::Attributes::Integer.new }

  describe '#cast' do
    subject { -> { type.cast value } }

    context 'with nil' do
      let(:value) { nil }
      it { expect(subject.call).to eq nil }
    end

    context 'with empty string' do
      let(:value) { '' }
      it { expect(subject.call).to eq 0 }
    end

    context 'with blank string' do
      let(:value) { "  \t" }
      it { expect(subject.call).to eq 0 }
    end

    context 'with string' do
      let(:value) { '123' }
      it { expect(subject.call).to eq 123 }
    end

    context 'with invalid string' do
      let(:value) { '123a' }
      it { is_expected.to raise_error ArgumentError }
    end
  end
end
