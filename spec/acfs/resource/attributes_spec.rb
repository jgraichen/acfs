# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Attributes do
  let(:model) { Class.new Acfs::Resource }
  let(:submodel) { Class.new model }

  describe '#initialize' do
    before { model.attribute :name, :string, default: 'John' }

    it 'has attribute list' do
      expect(model.new.attributes).to include(:name)
    end

    it 'sets default attributes' do
      expect(model.new.name).to eq 'John'
    end

    context 'with dynamic default value' do
      before do
        model.attribute :name, :string, default: 'John'
        model.attribute :mail, :string, default: -> { "#{name}@srv.tld" }
      end

      it 'sets dynamic default attributes' do
        expect(model.new.mail).to eq 'John@srv.tld'
      end
    end
  end

  describe '#attributes' do
    before do
      model.attribute :name, :string, default: 'John'
      model.attribute :age, :integer, default: 25
    end

    it 'returns hash of all attributes' do
      expect(model.new.attributes).to eq(name: 'John', age: 25)
    end
  end

  describe '#write_attributes' do
    subject(:action) { -> { m.write_attributes(params, **opts) } }

    before do
      model.attribute :name, :string, default: 'John'
      model.attribute :age, :integer, default: 25
      model.send :define_method, :name= do |name|
        write_attribute :name, "The Great #{name}"
      end
    end

    let(:params) { {name: 'James'} }
    let(:opts) { {} }
    let(:m) { model.new }

    it 'updates attributes' do
      expect(action).to change(m, :attributes)
        .from(name: 'The Great John', age: 25)
        .to(name: 'The Great James', age: 25)
    end

    context 'without non-hash params' do
      let(:params) { 'James' }

      it { expect(action).not_to change(m, :attributes) }
      it { expect(action.call).to be false }
    end

    context 'with unknown attributes' do
      let(:params) { {name: 'James', born_at: 'today'} }

      it { expect(action).not_to raise_error }

      it 'updates known attributes and store unknown' do
        expect(action).to change(m, :attributes)
          .from(name: 'The Great John', age: 25)
          .to(name: 'The Great James', age: 25, born_at: 'today')
      end

      context 'with unknown: :raise option' do
        let(:opts) { {unknown: :raise} }

        it { expect(action).to raise_error(ArgumentError, /unknown attribute/i) }

        it do
          expect do
            action.call
          rescue StandardError
            true
          end.not_to change(m, :attributes)
        end
      end
    end
  end

  describe '#_getter_' do
    before { model.attribute :name, :string, default: 'John' }

    it 'returns value' do
      mo = model.new
      mo.name = 'Paul'

      expect(mo.name).to eq 'Paul'
    end

    it 'returns default value' do
      expect(model.new.name).to eq 'John'
    end
  end

  describe '#_setter_' do
    before do
      model.attribute :name, :string, default: 'John'
      model.attribute :age, :integer, default: '25'
    end

    it 'sets value' do
      o = model.new
      o.name = 'Paul'

      expect(o.name).to eq 'Paul'
    end

    it 'updates attributes hash' do
      o = model.new
      o.name = 'Johannes'

      expect(o.attributes['name']).to eq 'Johannes'
    end

    it 'casts values' do
      o = model.new
      o.age = '28'

      expect(o.age).to eq 28
    end
  end

  describe 'class' do
    describe '#attributes' do
      it 'adds an attribute to model attribute list' do
        model.send :attribute, :name, :string

        expect(model.attributes.symbolize_keys).to eq name: nil
      end

      it 'accepts a default value' do
        model.send :attribute, :name, :string, default: 'John'

        expect(model.attributes.symbolize_keys).to eq name: 'John'
      end

      it 'accepts a symbolic type' do
        model.send :attribute, :age, :integer, default: '12'

        expect(model.attributes.symbolize_keys).to eq age: 12
      end

      it 'accepts a class type' do
        model.send :attribute, :age, Acfs::Resource::Attributes::Integer,
          default: '12'

        expect(model.attributes.symbolize_keys).to eq age: 12
      end

      context 'on inherited resources' do
        before do
          model.attribute :age, :integer, default: 5
          submodel.attribute :born_at, :date_time
        end

        it 'includes superclass attributes' do
          expect(submodel.attributes.keys).to match_array %w[age born_at]
        end
      end
    end
  end
end
