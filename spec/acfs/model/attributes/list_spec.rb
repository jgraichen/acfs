require 'spec_helper'

describe Acfs::Model::Attributes::List do
  let(:model) { Class.new.tap { |c| c.send :include, Acfs::Model }}
  subject { Acfs::Model::Attributes::List.new }

  describe '.cast' do
    context 'with array' do
      let(:sample) { %w(abc cde efg) }

      it 'should return unmodified array' do
        expect(subject.cast(sample)).to be == %w(abc cde efg)
      end
    end

    context 'with not listable object' do
      let(:sample) { Object.new }

      it 'should raise a TypeError' do
        expect {
          subject.cast(sample)
        }.to raise_error TypeError
      end
    end

    context 'with listable object' do
      let(:sample) { 5..10 }

      it 'should cast object to array' do
        expect(subject.cast(sample)).to be == [5, 6, 7, 8, 9, 10]
      end
    end
  end
end
