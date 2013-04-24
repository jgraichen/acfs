require 'spec_helper'

describe Acfs::Model::Attributes do
  let(:model) { Class.new.tap { |c| c.send :include, Acfs::Model }}

  describe '#initialize' do
    before { model.attribute :name, :string, default: 'John' }

    it 'should have attribute list' do
      expect(model.new.attributes).to include(:name)
    end

    it 'should set default attributes' do
      expect(model.new.name).to be == 'John'
    end

    context 'with dynamic default value' do
      before do
        model.attribute :name, :string, default: 'John'
        model.attribute :mail, :string, default: -> { "#{name}@srv.tld" }
      end

      it 'should set dynamic default attributes' do
        expect(model.new.mail).to be == 'John@srv.tld'
      end
    end
  end

  describe '#attributes' do
    before do
      model.attribute :name, :string, default: 'John'
      model.attribute :age, :integer, default: 25
    end

    it 'should return hash of all attributes' do
      expect(model.new.attributes).to be == { name: 'John', age: 25 }.stringify_keys
    end
  end

  describe '#write_attributes' do
    before do
      model.attribute :name, :string, default: 'John'
      model.attribute :age, :integer, default: 25
    end
    let(:m) { model.new }

    it 'should update attributes' do
      m.write_attributes name: 'James'

      expect(m.attributes).to be == { name: 'James', age: 25 }.stringify_keys
    end

    it 'should do nothing on non-array types' do
      ret = m.write_attributes 'James'

      expect(ret).to be_false
      expect(m.attributes).to be == { name: 'John', age: 25 }.stringify_keys
    end
  end

  describe '#_getter_' do
    before { model.attribute :name, :string, default: 'John' }

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
    before do
      model.attribute :name, :string, default: 'John'
      model.attribute :age, :integer, default: '25'
    end

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

    it 'should cast values' do
      o = model.new
      o.age = "28"

      expect(o.age).to be == 28
    end
  end

  describe '.attribute' do
    it 'should add an attribute to model attribute list' do
      model.send :attribute, :name, :string

      expect(model.attributes).to be == { :name => nil }
    end

    it 'should accept a default value' do
      model.send :attribute, :name, :string, default: 'John'

      expect(model.attributes).to be == { :name => 'John' }
    end

    it 'should accept an symbolic type' do
      model.send :attribute, :age, :integer, default: '12'

      expect(model.attributes).to be == { :age => 12 }
    end

    it 'should accept an class type' do
      model.send :attribute, :age, Acfs::Model::Attributes::Integer, default: '12'

      expect(model.attributes).to be == { :age => 12 }
    end
  end
end
