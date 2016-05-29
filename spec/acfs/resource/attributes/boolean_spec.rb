require 'spec_helper'

describe Acfs::Resource::Attributes::Boolean do
  subject { Acfs::Resource::Attributes::Boolean.new }

  describe '#cast' do
    it 'casts nil' do
      expect(subject.cast(nil)).to eq nil
    end

    it 'casts empty string to false' do
      expect(subject.cast('')).to eq nil
    end

    it 'casts blank string to false' do
      expect(subject.cast("  \t")).to eq nil
    end

    it 'preserves boolean values' do
      expect(subject.cast(false)).to eq false
      expect(subject.cast(true)).to eq true
    end

    it 'casts TRUE_VALUES to true' do
      expect(subject.cast(1)).to eq true
      expect(subject.cast('yes')).to eq true
      expect(subject.cast('on')).to eq true
      expect(subject.cast('true')).to eq true
      expect(subject.cast('1')).to eq true
    end

    it 'casts any other value to false' do
      expect(subject.cast(0)).to eq false
      expect(subject.cast(2)).to eq false
      expect(subject.cast('wrong')).to eq false
      expect(subject.cast('random')).to eq false
    end
  end
end
