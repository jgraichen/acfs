require 'spec_helper'

describe Acfs::Model::Attributes::Boolean do
  subject { Acfs::Model::Attributes::Boolean.new }

  describe 'cast' do
    it 'should preserve boolean values' do
      expect(subject.cast(false)).to eq false
      expect(subject.cast(true)).to eq true
    end

    it 'should cast TRUE_VALUES to true' do
      expect(subject.cast('yes')).to eq true
      expect(subject.cast('on')).to eq true
      expect(subject.cast('true')).to eq true
      expect(subject.cast('1')).to eq true
    end

    it 'should cast any other value to false' do
      expect(subject.cast('')).to eq false
      expect(subject.cast('wrong')).to eq false
      expect(subject.cast('random')).to eq false
    end
  end
end
