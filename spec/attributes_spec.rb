require 'spec_helper'

describe Acfs::Attributes do
  let(:model) { Class.new.tap { |c| c.send :include, Acfs::Attributes }}

  describe '#initialize' do
    before { model.send :attribute, :name, default: 'John' }

    it 'should have attribute list' do
      expect(model.new.attributes).to include('name')
    end

    it 'should set default attributes' do
      expect(model.new.name).to be == 'John'
    end
  end

  describe '#attributes' do
    before do
      model.send :attribute, :name, default: 'John'
      model.send :attribute, :age, type: :integer, default: 25
    end

    it 'should return hash of all attributes' do
      expect(model.new.attributes).to be == {
          'name' => 'John',
          'age' => 25
      }
    end
  end

  describe '#_getter_' do
    before { model.send :attribute, :name, default: 'John' }

    it 'should return value' do
      mo = model.new
      mo.name = 'Paul'

      expect(mo.name).to be == 'Paul'
    end

    it 'should return default value' do
      expect(model.new.name).to be == 'John'
    end

    it 'should return matching ivar\'s value' do
      o = model.new
      o.instance_variable_set :@name, 'Johannes'

      expect(o.name).to be == 'Johannes'
    end
  end

  describe '#_setter_' do
    before { model.send :attribute, :name, default: 'John' }

    it 'should set value' do
      o = model.new
      o.name = 'Paul'

      expect(o.name).to be == 'Paul'
    end

    it 'should set instance var' do
      o = model.new
      o.name = 'Paul'

      expect(o.instance_variable_get(:@name)).to be == 'Paul'
    end

    it 'should update attributes hash' do
      o = model.new
      o.name = 'Johannes'

      expect(o.attributes['name']).to be == 'Johannes'
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
