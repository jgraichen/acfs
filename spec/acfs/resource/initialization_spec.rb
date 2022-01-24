# frozen_string_literal: true

require 'spec_helper'

describe 'Acfs::Resource::Initialization' do
  let(:model) do
    Class.new(Acfs::Resource).tap do |c|
      c.class_eval do
        attr_accessor :name
        attr_reader :age

        private

        attr_writer :age
      end
    end
  end

  describe '#initialize' do
    it 'allows to set attributes with initializer' do
      m = model.new name: 'John'
      expect(m.name).to eq 'John'
    end

    it 'raises error when attributes with private setters are given' do
      expect { model.new age: 25 }.to raise_error(NoMethodError)
    end
  end

  describe '#persisted?' do
    it 'is false' do
      expect(model.new.persisted?).to be false
    end
  end
end
