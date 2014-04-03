require 'spec_helper'

describe 'Acfs::Resource::Initialization' do
  let(:model) do
    Class.new(Acfs::Resource).tap do |c|
      c.class_eval do
        attr_accessor :name, :age
        private :age=
      end
    end
  end

  describe '#initialize' do
    it 'should allow to set attributes with initializer' do
      m = model.new name: 'John'
      expect(m.name).to eq 'John'
    end

    it 'should raise error when attributes with private setters are given' do
      expect { model.new age: 25 }.to raise_error(NoMethodError)
    end
  end

  describe '#persisted?' do
    subject { model.new.persisted? }
    it 'should be false' do
      should be false
    end
  end
end
