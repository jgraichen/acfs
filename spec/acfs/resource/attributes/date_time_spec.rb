# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Attributes::DateTime do
  let(:type) { Acfs::Resource::Attributes::DateTime.new }

  describe '#cast' do
    subject(:cast) { -> { type.cast value } }

    context 'with nil' do
      let(:value) { nil }

      it { expect(cast.call).to eq nil }
    end

    context 'with empty string' do
      let(:value) { '' }

      it { expect(cast.call).to eq nil }
    end

    context 'with blank string' do
      let(:value) { "  \t" }

      it { expect(cast.call).to eq nil }
    end

    context 'with DateTime' do
      let(:value) { DateTime.now }

      it { expect(cast.call).to eq value }
    end

    context 'with Time' do
      let(:value) { Time.now }

      it { expect(cast.call).to eq value.to_datetime }
    end

    context 'with Date' do
      let(:value) { Date.today }

      it { expect(cast.call).to eq value.to_datetime }
    end

    context 'with ISO8601' do
      let(:value) { DateTime.now.iso8601 }

      it { expect(cast.call.iso8601).to eq value }
    end

    context 'with invalid string' do
      let(:value) { 'qwe123' }

      it { is_expected.to raise_error ArgumentError }
    end
  end
end
