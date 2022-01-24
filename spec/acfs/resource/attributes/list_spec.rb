# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Attributes::List do
  let(:type) { Acfs::Resource::Attributes::List.new }

  describe '#cast' do
    subject(:cast) { -> { type.cast value } }

    context 'with nil' do
      let(:value) { nil }

      it { expect(cast.call).to eq nil }
    end

    context 'with blank string (I)' do
      let(:value) { '' }

      it { expect(cast.call).to eq [] }
    end

    context 'with blank string (II)' do
      let(:value) { "  \t" }

      it { expect(cast.call).to eq [] }
    end

    context 'with array' do
      let(:value) { %w[abc cde efg] }

      it { expect(cast.call).to eq value }
    end

    context 'with convertable object (I)' do
      let(:value) do
        Class.new do
          def to_ary
            [1, 2, 3]
          end
        end.new
      end

      it { expect(cast.call).to eq [1, 2, 3] }
    end

    context 'with convertable object (II)' do
      let(:value) do
        Class.new do
          def to_a
            [1, 2, 3]
          end
        end.new
      end

      it { expect(cast.call).to eq [1, 2, 3] }
    end

    context 'with non castable object' do
      let(:value) { Object.new }

      it { expect(cast.call).to eq [value] }
    end
  end
end
