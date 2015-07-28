require 'spec_helper'

describe Acfs::Resource::Attributes::Integer do
  subject { Acfs::Resource::Attributes::Integer.new }

  describe 'cast' do
    it 'should cast integer strings' do
      expect(subject.cast('123')).to eq 123
    end

    it 'should cast empty string (backward compatibility)' do
      expect(subject.cast('')).to eq 0
    end

    it 'should not cast invalid integers' do
      expect { subject.cast 'abc' }.to raise_error TypeError
    end
  end
end
