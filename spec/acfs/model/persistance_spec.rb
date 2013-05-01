require 'spec_helper'

describe Acfs::Model::Persistence do
  let(:model_class) { MyUser }
  before do
    @get_stub = stub_request(:get, "http://users.example.org/users/1").to_return(
        body: MessagePack.dump({ id: 1, name: "Anon", age: 12 }),
        headers: {'Content-Type' => 'application/x-msgpack'})

    @patch_stub = stub_request(:put, 'http://users.example.org/users/1')
        .with(
          body: '{"id":1,"name":"Idefix","age":12}')
        .to_return(
          body: MessagePack.dump({ id: 1, name: 'Idefix', age: 12 }),
          headers: {'Content-Type' => 'application/x-msgpack'})

    @post_stub = stub_request(:post, 'http://users.example.org/users')
    .with(body: '{"id":null,"name":"Idefix","age":12}')
    .to_return(
        body: MessagePack.dump({ id: 5, name: 'Idefix', age: 12 }),
        headers: {'Content-Type' => 'application/x-msgpack'})

    stub_request(:post, 'http://users.example.org/users')
    .with(body: '{"id":null,"name":"Anon","age":null}')
    .to_return(
        body: MessagePack.dump({ id: 5, name: 'Anon', age: 12 }),
        headers: {'Content-Type' => 'application/x-msgpack'})

    stub_request(:post, 'http://users.example.org/users')
    .with(body: '{"name":"Idefix","age":12}')
    .to_return(
        body: MessagePack.dump({ id: 5, name: 'Idefix', age: 12 }),
        headers: {'Content-Type' => 'application/x-msgpack'})

    stub_request(:post, 'http://users.example.org/users')
    .with(body: '{"age":12}')
    .to_return(
        status: 422,
        body: MessagePack.dump({ errors: { name: [ 'required' ] }}),
        headers: {'Content-Type' => 'application/x-msgpack'})
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
      end
    end

    context 'after save' do
      before { model.save! }

      it { expect(model).to be_persisted }
      it { expect(model).to_not be_new }
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
      before { model; Acfs.run; model.name = "dhh" }

      it { expect(model).to_not be_persisted }
      it { expect(model).to_not be_new }
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
      let(:data) { { age: 12 } }

      it 'should raise an error' do
        expect { model_class.create! data }.to raise_error ::Acfs::InvalidResource do |error|
          expect(error.errors).to be == { name: ['required'] }.stringify_keys
        end
      end
    end
  end

  describe '.create' do
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
      let(:data) { { age: 12 } }

      it 'should return not persisted resource' do
        model = model_class.create data
        expect(model).to_not be_persisted
      end

      it 'should contain error hash' do
        model = model_class.create data
        expect(model.errors.to_hash).to be == { name: [ "required" ]}.stringify_keys
      end
    end
  end
end
