require 'spec_helper'

describe Acfs::Resource::Persistence do
  let(:model_class) { MyUser }
  before do
    @get_stub = stub_request(:get, 'http://users.example.org/users/1').to_return response({ id: 1, name: 'Anon', age: 12 })

    @patch_stub = stub_request(:put, 'http://users.example.org/users/1')
      .with(body: '{"id":1,"name":"Idefix","age":12}')
      .to_return response({ id: 1, name: 'Idefix', age: 12 })

    @post_stub = stub_request(:post, 'http://users.example.org/users')
      .with(body: '{"id":null,"name":"Idefix","age":12}')
      .to_return response({ id: 5, name: 'Idefix', age: 12 })

    stub_request(:post, 'http://users.example.org/users')
      .with(body: '{"id":null,"name":"Anon","age":null}')
      .to_return response({ id: 5, name: 'Anon', age: 12 })

    stub_request(:post, 'http://users.example.org/users')
      .with(body: '{id:null,"name":"Idefix","age":12}')
      .to_return response({ id: 5, name: 'Idefix', age: 12 })

    stub_request(:post, 'http://users.example.org/users')
      .with(body: '{"id":null,"name":null,"age":12}')
      .to_return response({ errors: { name: [ 'required' ] }}, status: 422)

    @del = stub_request(:delete, 'http://users.example.org/users/1')
      .with(body: '{}')
      .to_return response({ id: 1, name: 'Idefix', age: 12 }, status: 200)
  end

  context 'new model' do
    let(:model) { model_class.new }

    it { expect(model).to_not be_persisted }
    it { expect(model).to be_new }

    describe '#save!' do
      context 'when modified' do
        let(:model) { model_class.find 1 }
        before do
          model
          Acfs.run
          model.name = 'Idefix'
        end

        it 'should PUT to model URL' do
          model.save!

          expect(@patch_stub).to have_been_requested
        end
      end

      context 'when new' do
        let(:model) { model_class.new name: 'Idefix', age: 12 }

        it 'should POST to collection URL' do
          model.save!

          expect(@post_stub).to have_been_requested
        end

        context 'with unknown attributes' do
          let!(:req) do
            stub_request(:post, 'http://users.example.org/users')
              .with(body: '{"id":null,"name":"Idefix","age":null,"born_at":"Berlin"}')
              .to_return response({id: 5, name: 'Idefix', age: 12, wuff: 'woa'})
          end
          let(:model) { model_class.new name: 'Idefix', born_at: 'Berlin' }

          it 'should POST to collection URL' do
            model.save!
            expect(req).to have_been_requested
          end

          it 'should still have unknown attribute' do
            model.save!
            expect(model.attributes).to include 'born_at' => 'Berlin'
          end

          it 'should include server send unknown attribute' do
            model.save!
            expect(model.attributes).to include 'wuff' => 'woa'
          end
        end
      end
    end

    context 'after save' do
      before { model.save! }

      it { expect(model).to be_persisted }
      it { expect(model).to_not be_new }
    end
  end

  context 'unloaded model' do
    let!(:model) { model_class.find 1 }

    describe '#update_attributes' do
      subject { -> { model.update_attributes name: 'John' } }
      it { expect{ subject.call }.to raise_error Acfs::ResourceNotLoaded }
    end

    describe '#update_attributes!' do
      subject { -> { model.update_attributes! name: 'John' } }
      it { expect{ subject.call }.to raise_error Acfs::ResourceNotLoaded }
    end
  end

  context 'loaded model' do
    context 'without changes' do
      let(:model) { model_class.find 1 }
      before { model; Acfs.run }

      it { expect(model).to be_persisted }
      it { expect(model).to_not be_new }
    end

    context 'with changes' do
      let(:model) { model_class.find 1 }
      before { model; Acfs.run; model.name = 'dhh' }

      it { expect(model).to_not be_persisted }
      it { expect(model).to_not be_new }
    end

    describe '#delete!' do
      let(:model) { model_class.find 1 }
      before { model; Acfs.run }

      it 'should trigger DELETE request' do
        model.delete!
        expect(@del).to have_been_requested
      end

      it 'should be frozen after DELETE' do
        model.delete!
        expect(model.__getobj__).to be_frozen
      end
    end

    describe '#update_atributes!' do
      let(:model) { model_class.find 1 }
      before { model; Acfs.run }

      it 'should set attributes' do
        model.update_attributes name: 'Idefix'
        expect(model.attributes.symbolize_keys).to eq id: 1, name: 'Idefix', age: 12
      end

      it 'should save resource' do
        expect(model.__getobj__).to receive(:save).with({})
        model.update_attributes name: 'Idefix'
      end

      it 'should pass second hash to save' do
        expect(model.__getobj__).to receive(:save).with({ bla: 'blub' })
        model.update_attributes({ name: 'Idefix' }, { bla: 'blub' })
      end
    end

    describe '#update_atributes' do
      let(:model) { model_class.find 1 }
      before { model; Acfs.run }

      it 'should set attributes' do
        model.update_attributes! name: 'Idefix'
        expect(model.attributes.symbolize_keys).to eq id: 1, name: 'Idefix', age: 12
      end

      it 'should save resource' do
        expect(model.__getobj__).to receive(:save!).with({})
        model.update_attributes! name: 'Idefix'
      end

      it 'should pass second hash to save' do
        expect(model.__getobj__).to receive(:save!).with({ bla: 'blub' })
        model.update_attributes!({ name: 'Idefix' }, { bla: 'blub' })
      end
    end
  end

  describe '.save!' do
    context 'with invalid data validated on server side' do
      let(:model) { model_class.find 1 }
      before { model; Acfs.run }

      before do
        stub_request(:put, 'http://users.example.org/users/1')
          .with(body: '{"id":1,"name":"","age":12}')
          .to_return response({ errors: { name: [ 'required' ] }}, status: 422)
      end

      it 'should set local errors hash' do
        model.name = ''
        model.save! rescue nil
        expect(model.errors.to_hash).to be == { name: %w(required) }
      end
    end

    context 'hash modification on iteration in ActiveModel when errors on field is nil' do
      let(:model) { model_class.find 1 }
      before { model; Acfs.run }

      before do
        stub_request(:put, 'http://users.example.org/users/1')
        .with(body: '{"id":1,"name":"","age":12}')
        .to_return response({ errors: { name: [ 'required' ] }}, status: 422)
      end
    end
  end

  describe '.create!' do
    context 'with valid data' do
      let(:data) { { name: 'Idefix', age: 12 } }

      it 'should create new resource' do
        model = model_class.create! data
        expect(model.name).to be == 'Idefix'
        expect(model.age).to be == 12
      end

      it 'should be persisted' do
        model = model_class.create! data
        expect(model).to be_persisted
      end
    end

    context 'with invalid data' do
      let(:data) { {name: nil, age: 12} }

      it 'should raise an error' do
        expect{ model_class.create! data }.to \
          raise_error(::Acfs::InvalidResource) do |error|
            expect(error.errors).to be == { 'name' => %w(required) }
          end
      end
    end
  end

  describe '.create' do
    subject { model_class.create data }

    context 'with valid data' do
      let(:data) { {name: 'Idefix', age: 12} }

      it 'should create new resource' do
        expect(subject.name).to be == 'Idefix'
        expect(subject.age).to be == 12
      end

      it 'should be persisted' do
        expect(subject).to be_persisted
      end
    end

    context 'with invalid data' do
      let(:data) { {name: nil, age: 12} }

      it 'should return not persisted resource' do
        expect(subject).to_not be_persisted
      end

      it 'should contain error hash' do
        expect(subject.errors.to_hash).to eq name: %w(required)
      end
    end

    context 'with additional data' do
      let!(:req) do
        stub_request(:post, 'http://users.example.org/users')
          .with(body: '{"id":null,"name":"Anon","age":9,"born_at":"today"}')
          .to_return response({id: 5, name: 'Anon', age: 9})
      end
      let(:data) { {age: 9, born_at: 'today'} }

      it 'should store them in attributes' do
        expect(subject.attributes).to eq 'id' => 5, 'name' => 'Anon',
          'age' => 9, 'born_at' => 'today'
      end
    end
  end
end
