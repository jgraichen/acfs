require 'spec_helper'

describe Acfs::Attributes do
  let(:model) { Class.new(MyModel) }

  describe '#initialize' do
    before { model.send :attribute, :name, default: 'John' }

    it 'should have attribute list' do
      expect(model.new.attributes).to include('name')
    end

    it 'should set default attributes' do
      expect(model.new.name).to be == 'John'
    end
  end

  describe '.attribute' do
    it 'should add an attribute to model attribute list' do
      model.send :attribute, :name

      expect(model.attributes).to be == { :name => '' }
    end

    it 'should accept a default value' do
      model.send :attribute, :name, default: 'John'

      expect(model.attributes).to be == { :name => 'John' }
    end

    it 'should accept an symbolic type' do
      model.send :attribute, :age, type: :integer, default: '12'

      expect(model.attributes).to be == { :age => 12 }
    end

    it 'should accept an class type' do
      model.send :attribute, :age, type: Acfs::Attributes::Integer, default: '12'

      expect(model.attributes).to be == { :age => 12 }
    end
  end
end
