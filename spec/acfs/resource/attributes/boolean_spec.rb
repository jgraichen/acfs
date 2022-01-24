# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Attributes::Boolean do
  subject(:type) { Acfs::Resource::Attributes::Boolean.new }

  describe '#cast' do
    it 'casts nil' do
      expect(type.cast(nil)).to eq nil
    end

    it 'casts empty string to false' do
      expect(type.cast('')).to eq nil
    end

    it 'casts blank string to false' do
      expect(type.cast("  \t")).to eq nil
    end

    it 'preserves boolean values' do
      expect(type.cast(false)).to eq false
      expect(type.cast(true)).to eq true
    end

    it 'casts falsy values to false' do
      expect(type.cast(false)).to eq false
      expect(type.cast(0)).to eq false
      expect(type.cast('0')).to eq false
      expect(type.cast('no')).to eq false
      expect(type.cast('NO')).to eq false
      expect(type.cast('off')).to eq false
      expect(type.cast('OFF')).to eq false
      expect(type.cast('false')).to eq false
      expect(type.cast('FALSE')).to eq false
      expect(type.cast('f')).to eq false
      expect(type.cast('F')).to eq false
    end

    it 'casts any other value to true' do
      expect(type.cast(true)).to eq true
      expect(type.cast(1)).to eq true
      expect(type.cast('1')).to eq true
      expect(type.cast('yes')).to eq true
      expect(type.cast('YES')).to eq true
      expect(type.cast('on')).to eq true
      expect(type.cast('ON')).to eq true
      expect(type.cast('true')).to eq true
      expect(type.cast('TRUE')).to eq true
      expect(type.cast('t')).to eq true
      expect(type.cast('T')).to eq true

      expect(type.cast(2)).to eq true
      expect(type.cast('wrong')).to eq true
      expect(type.cast('random')).to eq true
    end
  end
end
