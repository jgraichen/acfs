require 'spec_helper'

describe Acfs::Initialization do
  let(:model) { MyModel }

  describe '#initialize' do
    it 'should allow to set attributes with initializer' do
      model = MyModel.new(name: "John")
      expect(model.name).to be == "John"
    end

    it 'should raise error when attributes with private setters are given' do
      expect { MyModel.new(age: 25) }.to raise_error(NoMethodError)
    end
  end

  describe '#persisted?' do
    it 'should be false' do
      expect(MyModel.new.persisted?).to be_false
    end
  end
end
