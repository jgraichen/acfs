require 'spec_helper'

describe Acfs::Model::QueryMethods do
  let(:model) { MyUser }

  describe '.find' do
    context 'with single id' do
      context 'with successful response' do
        before do
          stub_request(:get, 'http://users.example.org/users/1').to_return response({ id: 1, name: 'Anon', age: 12 })
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

      context 'with 404 response' do
        before do
          stub_request(:get, 'http://users.example.org/users/1').to_return response({ error: 'not found' }, status: 404)
        end

        it 'should raise a NotFound error' do
          @user = model.find 1

          expect { Acfs.run }.to raise_error(Acfs::ResourceNotFound)

          expect(@user).to_not be_loaded
        end
      end

      context 'with 500 response' do
        before do
          stub_request(:get, 'http://users.example.org/users/1').to_return response(nil, status: 500)
        end

        it 'should raise a response error' do
          @user = model.find 1

          expect { Acfs.run }.to raise_error(Acfs::ErroneousResponse)

          expect(@user).to_not be_loaded
        end
      end
    end

    context 'with multiple ids' do
      before do
        stub_request(:get, 'http://users.example.org/users/1').to_return response({ id: 1, name: 'Anon', age: 12 })
        stub_request(:get, 'http://users.example.org/users/2').to_return response({ id: 2, name: 'Johnny', age: 42 })
      end

      context 'with successful response' do
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

      context 'with one 404 response' do
        before do
          stub_request(:get, 'http://users.example.org/users/1').to_return response({ error: 'not found' }, status: 404)
        end

        it 'should raise resource not found error' do
          model.find 1, 2

          expect { Acfs.run }.to raise_error(Acfs::ResourceNotFound)
        end
      end
    end
  end

  describe '.all' do
    let(:computer) { Computer }
    let(:pc) { PC }
    let(:mac) { Mac }
    before do
      stub_request(:get, 'http://computers.example.org/computers').to_return response([{ id: 1, type: 'PC' }, { id: 2, type: 'Computer' }, { id: 3, type: 'Mac' }])
    end

    context 'with resource type inheritance' do
      it 'should create appropriate subclass resources' do
        @computers = Computer.all

        expect(@computers).to_not be_loaded

        Acfs.run

        expect(@computers).to be_loaded
        expect(@computers).to have(3).items
        expect(@computers[0]).to be_a PC
        expect(@computers[1]).to be_a Computer
        expect(@computers[2]).to be_a Mac
      end
    end
  end
end
