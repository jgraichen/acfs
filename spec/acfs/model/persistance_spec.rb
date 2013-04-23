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

    @post_stub = stub_request(:post, 'http://users.example.org/users').to_return(
        body: MessagePack.dump({ id: 5, name: 'Idefix', age: 12 }),
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
end
