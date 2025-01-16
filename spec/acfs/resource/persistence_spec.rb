# frozen_string_literal: true

require 'spec_helper'

describe Acfs::Resource::Persistence do
  let(:model_class) { MyUser }

  let!(:patch_stub) do
    stub_request(:put, 'http://users.example.org/users/1')
      .with(body: '{"id":1,"name":"Idefix","age":12}')
      .to_return response(id: 1, name: 'Idefix', age: 12)
  end

  let!(:post_stub) do
    stub_request(:post, 'http://users.example.org/users')
      .with(body: '{"id":null,"name":"Idefix","age":12}')
      .to_return response(id: 5, name: 'Idefix', age: 12)
  end

  let!(:delete_stub) do
    stub_request(:delete, 'http://users.example.org/users/1')
      .with(body: '{}')
      .to_return response({id: 1, name: 'Idefix', age: 12}, {status: 200})
  end

  before do
    stub_request(:get, 'http://users.example.org/users/1')
      .to_return response(id: 1, name: 'Anon', age: 12)

    stub_request(:post, 'http://users.example.org/users')
      .with(body: '{"id":null,"name":"Anon","age":null}')
      .to_return response(id: 5, name: 'Anon', age: 12)

    stub_request(:post, 'http://users.example.org/users')
      .with(body: '{id:null,"name":"Idefix","age":12}')
      .to_return response(id: 5, name: 'Idefix', age: 12)

    stub_request(:post, 'http://users.example.org/users')
      .with(body: '{"id":null,"name":null,"age":12}')
      .to_return response({errors: {name: ['required']}}, {status: 422})
  end

  context 'new model' do
    let(:model) { model_class.new }

    it { expect(model).not_to be_persisted }
    it { expect(model).to be_new }

    describe '#save!' do
      context 'when modified' do
        let(:model) { model_class.find 1 }

        before do
          model
          Acfs.run
          model.name = 'Idefix'
        end

        it 'PUTS to model URL' do
          model.save!

          expect(patch_stub).to have_been_requested
        end
      end

      context 'when new' do
        let(:model) { model_class.new name: 'Idefix', age: 12 }

        it 'POSTS to collection URL' do
          model.save!

          expect(post_stub).to have_been_requested
        end

        context 'with unknown attributes' do
          let!(:req) do
            stub_request(:post, 'http://users.example.org/users')
              .with(body: '{"id":null,"name":"Idefix","age":null,"born_at":"Berlin"}')
              .to_return response(id: 5, name: 'Idefix', age: 12, wuff: 'woa')
          end
          let(:model) { model_class.new name: 'Idefix', born_at: 'Berlin' }

          it 'POSTS to collection URL' do
            model.save!
            expect(req).to have_been_requested
          end

          it 'stills have unknown attribute' do
            model.save!
            expect(model.attributes).to include 'born_at' => 'Berlin'
          end

          it 'includes server send unknown attribute' do
            model.save!
            expect(model.attributes).to include 'wuff' => 'woa'
          end
        end
      end
    end

    context 'after save' do
      before { model.save! }

      it { expect(model).to be_persisted }
      it { expect(model).not_to be_new }
    end
  end

  context 'unloaded model' do
    let!(:model) { model_class.find 1 }

    describe '#update_attributes' do
      it 'to raise error' do
        expect do
          model.update_attributes({name: 'John'})
        end.to raise_error Acfs::ResourceNotLoaded
      end
    end

    describe '#update_attributes!' do
      it 'to raise error' do
        expect do
          model.update_attributes!({name: 'John'})
        end.to raise_error Acfs::ResourceNotLoaded
      end
    end
  end

  context 'loaded model' do
    context 'without changes' do
      let(:model) { model_class.find 1 }

      before do
        model
        Acfs.run
      end

      it { expect(model).to be_persisted }
      it { expect(model).not_to be_new }
    end

    context 'with changes' do
      let(:model) { model_class.find 1 }

      before do
        model
        Acfs.run
        model.name = 'dhh'
      end

      it { expect(model).to be_persisted }
      it { expect(model).not_to be_new }
    end

    describe '#delete!' do
      let(:model) { model_class.find 1 }

      describe 'normal delete actions' do
        before do
          model
          Acfs.run
        end

        it 'triggers DELETE request' do
          model.delete!
          expect(delete_stub).to have_been_requested
        end

        it 'is frozen after DELETE' do
          model.delete!
          expect(model.__getobj__).to be_frozen
        end
      end

      describe 'correct URL generation' do
        let(:model_class) { PathArguments }
        let(:model) { model_class.find 1, params: {required_arg: 'some_value'} }
        let(:resource_url) { 'http://users.example.org/some_value/users/1' }

        let!(:delete_stub) do
          stub_request(:delete, resource_url)
            .with(body: '{}')
            .to_return response({id: 1, required_arg: 'some_value'}, {status: 200})
        end

        before do
          stub_request(:get, resource_url)
            .to_return response(id: 1, required_arg: 'some_value')

          model
          Acfs.run
        end

        it 'does not raise an error on URL generation' do
          expect do
            model.delete!
          end.not_to raise_error
        end

        it 'requests the delete' do
          model.delete!
          expect(delete_stub).to have_been_requested
        end
      end
    end

    describe '#update_atributes!' do
      let(:model) { model_class.find 1 }

      before do
        model
        Acfs.run
      end

      it 'sets attributes' do
        model.update_attributes({name: 'Idefix'})
        expect(model.attributes.symbolize_keys).to eq id: 1, name: 'Idefix', age: 12
      end

      it 'saves resource' do
        expect(model.__getobj__).to receive(:save)
        model.update_attributes({name: 'Idefix'})
      end

      it 'kwargses to save' do
        expect(model.__getobj__).to receive(:save).with(bla: 'blub')
        model.update_attributes({name: 'Idefix'}, bla: 'blub')
      end
    end

    describe '#update_atributes' do
      let(:model) { model_class.find 1 }

      before do
        model
        Acfs.run
      end

      it 'sets attributes' do
        model.update_attributes!({name: 'Idefix'})
        expect(model.attributes.symbolize_keys).to eq id: 1, name: 'Idefix', age: 12
      end

      it 'saves resource' do
        expect(model.__getobj__).to receive(:save!)
        model.update_attributes!({name: 'Idefix'})
      end

      it 'passes second hash to save' do
        expect(model.__getobj__).to receive(:save!).with(bla: 'blub')
        model.update_attributes!({name: 'Idefix'}, bla: 'blub')
      end
    end
  end

  describe '.save!' do
    context 'with invalid data validated on server side' do
      let(:model) { model_class.find 1 }

      before do
        model
        Acfs.run
      end

      before do
        stub_request(:put, 'http://users.example.org/users/1')
          .with(body: '{"id":1,"name":"","age":12}')
          .to_return response({errors: {name: ['required']}}, {status: 422})
      end

      it 'sets local errors hash' do
        model.name = ''
        begin
          model.save!
        rescue StandardError
          nil
        end
        expect(model.errors.to_hash).to eq({name: %w[required]})
      end
    end
  end

  describe '.create!' do
    context 'with valid data' do
      let(:data) { {name: 'Idefix', age: 12} }

      it 'creates new resource' do
        model = model_class.create! data
        expect(model.name).to eq 'Idefix'
        expect(model.age).to eq 12
      end

      it 'is persisted' do
        model = model_class.create! data
        expect(model).to be_persisted
      end
    end

    context 'with invalid data' do
      let(:data) { {name: nil, age: 12} }

      it 'raises an error' do
        expect { model_class.create! data }.to \
          raise_error(Acfs::InvalidResource) do |error|
            expect(error.errors).to eq({'name' => %w[required]})
          end
      end
    end
  end

  describe '.create' do
    subject(:model) { model_class.create data }

    context 'with valid data' do
      let(:data) { {name: 'Idefix', age: 12} }

      it 'creates new resource' do
        expect(model.name).to eq 'Idefix'
        expect(model.age).to eq 12
      end

      it 'is persisted' do
        expect(model).to be_persisted
      end
    end

    context 'with invalid data' do
      let(:data) { {name: nil, age: 12} }

      it 'returns not persisted resource' do
        expect(model).not_to be_persisted
      end

      it 'contains error hash' do
        expect(model.errors.to_hash).to eq name: %w[required]
      end
    end

    context 'with additional data' do
      before do
        stub_request(:post, 'http://users.example.org/users')
          .with(body: '{"id":null,"name":"Anon","age":9,"born_at":"today"}')
          .to_return response(id: 5, name: 'Anon', age: 9)
      end

      let(:data) { {age: 9, born_at: 'today'} }

      it 'stores them in attributes' do
        expect(model.attributes).to eq 'id' => 5, 'name' => 'Anon',
          'age' => 9, 'born_at' => 'today'
      end
    end
  end
end
