# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Attributes::Boolean do
  subject(:type) { Acfs::Resource::Attributes::Boolean.new }

  describe '#cast' do
    it 'casts nil' do
      expect(type.cast(nil)).to be_nil
    end

    it 'casts empty string to false' do
      expect(type.cast('')).to be_nil
    end

    it 'casts blank string to false' do
      expect(type.cast("  \t")).to be_nil
    end

    it 'preserves boolean values' do
      expect(type.cast(false)).to be false
      expect(type.cast(true)).to be true
    end

    it 'casts falsy values to false' do
      expect(type.cast(false)).to be false
      expect(type.cast(0)).to be false
      expect(type.cast('0')).to be false
      expect(type.cast('no')).to be false
      expect(type.cast('NO')).to be false
      expect(type.cast('off')).to be false
      expect(type.cast('OFF')).to be false
      expect(type.cast('false')).to be false
      expect(type.cast('FALSE')).to be false
      expect(type.cast('f')).to be false
      expect(type.cast('F')).to be false
    end

    it 'casts any other value to true' do
      expect(type.cast(true)).to be true
      expect(type.cast(1)).to be true
      expect(type.cast('1')).to be true
      expect(type.cast('yes')).to be true
      expect(type.cast('YES')).to be true
      expect(type.cast('on')).to be true
      expect(type.cast('ON')).to be true
      expect(type.cast('true')).to be true
      expect(type.cast('TRUE')).to be true
      expect(type.cast('t')).to be true
      expect(type.cast('T')).to be true

      expect(type.cast(2)).to be true
      expect(type.cast('wrong')).to be true
      expect(type.cast('random')).to be true
    end
  end
end
