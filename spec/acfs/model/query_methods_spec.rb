require 'spec_helper'

describe Acfs::Model::QueryMethods do
  let(:model) { MyUser }

  describe '.find' do
    context 'with single id' do
      before do
        stub_request(:get, 'http://users.example.org/users/1').to_return(
            body: MessagePack.dump({ id: 1, name: 'Anon', age: 12 }),
            headers: {'Content-Type' => 'application/x-msgpack'})
      end

      it 'should load a single remote resource' do
        user = model.find 1
        Acfs.run

        expect(user.attributes).to be == { id: 1, name: 'Anon', age: 12 }.stringify_keys
      end

      it 'should invoke callback after model is loaded' do
        proc = Proc.new { }
        proc.should_receive(:call) do |user|
          expect(user).to be === @user
          expect(user).to be_loaded
        end

        @user = model.find 1, &proc
        Acfs.run
      end
    end

    context 'with multiple ids' do
      before do
        stub_request(:get, 'http://users.example.org/users/1').to_return(
            body: MessagePack.dump({ id: 1, name: 'Anon', age: 12 }),
            headers: {'Content-Type' => 'application/x-msgpack'})
        stub_request(:get, 'http://users.example.org/users/2').to_return(
            body: MessagePack.dump({ id: 2, name: 'Johnny', age: 42 }),
            headers: {'Content-Type' => 'application/x-msgpack'})
      end

      it 'should load a multiple remote resources' do
        users = model.find 1, 2
        Acfs.run

        expect(users.size).to be == 2
        expect(users[0].attributes).to be == { id: 1, name: 'Anon', age: 12 }.stringify_keys
        expect(users[1].attributes).to be == { id: 2, name: 'Johnny', age: 42 }.stringify_keys
      end

      it 'should invoke callback after all models are loaded' do
        proc = Proc.new { }
        proc.should_receive(:call) do |users|
          expect(users).to be === @users
          expect(users.size).to be == 2
          expect(users).to be_loaded
        end

        @users = model.find 1, 2, &proc
        Acfs.run
      end
    end
  end
end
