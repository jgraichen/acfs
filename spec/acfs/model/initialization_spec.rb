require 'spec_helper'

describe 'Acfs::Model::Initialization' do
  let(:model) do
    Class.new.tap do |c|
      c.class_eval do
        include Acfs::Model
        attr_accessor :name, :age
        private :age=
      end
    end
  end

  describe '#initialize' do
    it 'should allow to set attributes with initializer' do
      m = model.new(name: "John")
      expect(m.name).to be == "John"
    end

    it 'should raise error when attributes with private setters are given' do
      expect { model.new(age: 25) }.to raise_error(NoMethodError)
    end
  end

  describe '#persisted?' do
    it 'should be false' do
      expect(model.new.persisted?).to be false
    end
  end
end
