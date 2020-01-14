# frozen_string_literal: true

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

    it 'casts falsy values to false' do
      expect(subject.cast(false)).to eq false
      expect(subject.cast(0)).to eq false
      expect(subject.cast('0')).to eq false
      expect(subject.cast('no')).to eq false
      expect(subject.cast('NO')).to eq false
      expect(subject.cast('off')).to eq false
      expect(subject.cast('OFF')).to eq false
      expect(subject.cast('false')).to eq false
      expect(subject.cast('FALSE')).to eq false
      expect(subject.cast('f')).to eq false
      expect(subject.cast('F')).to eq false
    end

    it 'casts any other value to true' do
      expect(subject.cast(true)).to eq true
      expect(subject.cast(1)).to eq true
      expect(subject.cast('1')).to eq true
      expect(subject.cast('yes')).to eq true
      expect(subject.cast('YES')).to eq true
      expect(subject.cast('on')).to eq true
      expect(subject.cast('ON')).to eq true
      expect(subject.cast('true')).to eq true
      expect(subject.cast('TRUE')).to eq true
      expect(subject.cast('t')).to eq true
      expect(subject.cast('T')).to eq true

      expect(subject.cast(2)).to eq true
      expect(subject.cast('wrong')).to eq true
      expect(subject.cast('random')).to eq true
    end
  end
end
