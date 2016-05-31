require 'spec_helper'

describe Acfs::Resource::Attributes::Dict do
  let(:type) { Acfs::Resource::Attributes::Dict.new }

  describe '#cast' do
    subject { -> { type.cast value } }

    context 'with nil' do
      let(:value) { nil }
      it { expect(subject.call).to eq nil }
    end

    context 'with blank string (I)' do
      let(:value) { '' }
      it { expect(subject.call).to eq Hash.new }
    end

    context 'with blank string (II)' do
      let(:value) { "  \t" }
      it { expect(subject.call).to eq Hash.new }
    end

    context 'with hash' do
      let(:value) { {3 => true, abc: 4} }
      it { expect(subject.call).to eq value }
    end

    context 'with non hashable object' do
      let(:value) { Object.new }
      it { is_expected.to raise_error TypeError }
    end

    context 'with hashable object (I)' do
      let(:value) do
        Class.new do
          def to_hash
            {id: object_id}
          end
        end.new
      end

      it { expect(subject.call).to eq id: value.object_id }
    end

    context 'with hashable object (II)' do
      let(:value) do
        Class.new do
          def to_h
            {id: object_id}
          end
        end.new
      end

      it { expect(subject.call).to eq id: value.object_id }
    end

    context 'with serializable object' do
      let(:value) do
        Class.new do
          def serializable_hash
            {id: object_id}
          end
        end.new
      end

      it { expect(subject.call).to eq id: value.object_id }
    end

    context 'with hash subclass object' do
      let(:value) { HashWithIndifferentAccess.new test: :foo }
      it { expect(subject.call).to be value }
    end
  end
end
