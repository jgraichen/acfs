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

    context 'with optional attribute' do
      before do
        model.attribute :name, :string, default: 'John'
        model.attribute :profile, :string, optional: true
      end

      it 'should not be included in attributes' do
        expect(model.new.attributes.keys).to match_array %w(name)
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

    context 'optional attribute' do
      before { model.attribute :profile, :string, optional: true }

      it 'should not be include if not set' do
        expect(model.new.attributes.keys).to_not include 'profile'
      end

      it 'should be include if set' do
        expect(model.new.tap{|m| m.profile = 'abc'}.attributes).to include 'profile' => 'abc'
      end
    end
  end

  describe '#write_attributes' do
    before do
      model.attribute :name, :string, default: 'John'
      model.attribute :age, :integer, default: 25
      model.send :define_method, :name= do |name|
        write_attribute :name, "The Great #{name}"
      end
    end
    let(:args) { [params] }
    let(:params){ {name: 'James'} }
    let(:m) { model.new }
    let(:action) { lambda{ m.write_attributes *args } }
    subject { action }

    it 'should update attributes'  do
      should change(m, :attributes)
             .from({'name' => 'The Great John', 'age' => 25})
             .to({'name' => 'The Great James', 'age' => 25})
    end

    context 'without non-hash params' do
      let(:params) { 'James' }

      it { should_not change(m, :attributes) }
      its(:call) { should eq false }
    end

    context 'with unknown attributes' do
      let(:params) { {name: 'James', born_at: 'today'} }

      it { should_not raise_error }

      it 'should update known attributes and store unknown'  do
        should change(m, :attributes)
               .from({'name' => 'The Great John', 'age' => 25})
               .to({'name' => 'The Great James', 'age' => 25, 'born_at' => 'today'})
      end

      context 'with unknown: :raise option' do
        let(:args) { [params, {unknown: :raise}] }

        it { should raise_error(ArgumentError, /unknown attribute/i) }
        it { expect{ subject.call rescue true }.to_not change(m, :attributes) }
      end
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

    context 'with optional attribute' do
      before { model.attribute :profile, :string, optional: true }

      it 'should have getter' do
        expect(model.new.profile).to eq nil
        expect(model.new(profile: 'abc').profile).to eq 'abc'
      end
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

    it 'should update attributes hash' do
      o = model.new
      o.name = 'Johannes'

      expect(o.attributes['name']).to be == 'Johannes'
    end

    it 'should cast values' do
      o = model.new
      o.age = '28'

      expect(o.age).to be == 28
    end

    context 'with optional attribute' do
      before { model.attribute :profile, :string, optional: true }

      it 'should have setter for optional attribute' do
        expect(model.new.tap{|m| m.profile = 'abc' }.profile).to eq 'abc'
      end
    end
  end

  describe 'class' do
    describe '#attribute' do
      it 'should add an attribute to model attribute list' do
        model.send :attribute, :name, :string

        expect(model.attributes).to be == { :name => nil }.stringify_keys
      end

      it 'should accept a default value' do
        model.send :attribute, :name, :string, default: 'John'

        expect(model.attributes).to be == { :name => 'John' }.stringify_keys
      end

      it 'should accept an symbolic type' do
        model.send :attribute, :age, :integer, default: '12'

        expect(model.attributes).to be == { :age => 12 }.stringify_keys
      end

      it 'should accept an class type' do
        model.send :attribute, :age, Acfs::Model::Attributes::Integer, default: '12'

        expect(model.attributes).to be == { :age => 12 }.stringify_keys
      end

      context 'allow nil option' do
        it 'should allow nil as value' do
          model.send :attribute, :updated_at, Acfs::Model::Attributes::DateTime, default: DateTime.new, allow_nil: true
          resource = model.new
          expect(resource.updated_at).to eq DateTime.new

          resource.updated_at = ''
          expect(resource.updated_at).to eq nil
        end
      end

      context 'allow blank option' do
        it 'should allow blank as value' do
          model.send :attribute, :updated_at, Acfs::Model::Attributes::DateTime, default: DateTime.new, allow_blank: true
          resource = model.new
          expect(resource.updated_at).to eq DateTime.new

          resource.updated_at = ''
          expect(resource.updated_at).to eq nil
        end
      end

      context 'optional' do
        it 'should fail with default' do
          expect do
            model.send :attribute, :abc, :integer, optional: true, default: 5
          end.to raise_error ArgumentError, /\AOptional attributes cannot have a default value\.\z/
        end
      end
    end
  end
end
