require 'spec_helper'

describe Acfs::Model::Attributes::Dict do
  let(:model) { Class.new.tap { |c| c.send :include, Acfs::Model }}
  subject { Acfs::Model::Attributes::Dict.new }

  describe '.cast' do
    context 'with hash' do
      let(:sample) { {3 => true, "asfd" => 4} }

      it 'should return unmodified hash' do
        expect(subject.cast(sample)).to be sample
      end
    end

    context 'with not hashable object' do
      let(:sample) { Object.new }

      it 'should raise a TypeError' do
        expect {
          subject.cast(sample)
        }.to raise_error TypeError
      end
    end

    context 'with hashable object' do
      let(:sample) do
        o = Object.new
        class << o
          def to_h
            {3 => 4, 'test' => true}
          end
        end
        o
      end

      it 'should cast object to hash' do
        expect(subject.cast(sample)).to eq 3 => 4, 'test' => true
      end
    end

    context 'with hash subclass' do
      let(:sample) { HashWithIndifferentAccess.new :test => :foo, 34 => 12 }

      it 'should return obj unmodified' do
        expect(subject.cast(sample)).to be sample
      end
    end
  end
end
