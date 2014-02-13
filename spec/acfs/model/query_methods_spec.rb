require 'spec_helper'

describe Acfs::Model::QueryMethods do
  let(:model) { MyUser }

  describe '.find' do
    context 'with single id' do
      context 'with successful response' do
        before do
          stub_request(:get, 'http://users.example.org/users/1').to_return response({ id: 1, name: 'Anon', age: 12 })
          stub_request(:get, 'http://users.example.org/users/2').to_return response({ id: 2, type: 'Customer', name: 'Clare Customer', age: 24 })
        end

        it 'should load a single remote resource' do
          user = model.find 1
          Acfs.run

          expect(user.attributes).to be == { id: 1, name: 'Anon', age: 12 }.stringify_keys
        end

        it 'should invoke callback after model is loaded' do
          proc = Proc.new { }
          expect(proc).to receive(:call) do |user|
            expect(user).to equal @user
            expect(user).to be_loaded
          end

          @user = model.find 1, &proc
          Acfs.run
        end

        it 'should invoke multiple callback after model is loaded' do
          proc1 = Proc.new { }
          proc2 = Proc.new { }
          expect(proc1).to receive(:call) do |user|
            expect(user).to equal @user
            expect(user).to be_loaded
          end
          expect(proc2).to receive(:call) do |user|
            expect(user).to equal @user
            expect(user).to be_loaded
          end

          @user = model.find 1, &proc1
          Acfs.add_callback(@user, &proc2)
          Acfs.run
        end

        context 'with resource type inheritance' do
          let!(:user) { MyUser.find 2 }
          subject { user }
          before { Acfs.run }

          it 'should respect resource type inheritance' do
            expect(subject).to be_a Customer
          end

          it 'should implement ActiveModel class interface' do
            expect(subject.class).to be_a ActiveModel::Naming
            expect(subject.class).to be_a ActiveModel::Translation
          end
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
        stub_request(:get, 'http://users.example.org/users/3').to_return response({ id: 3, type: 'Customer', name: 'Anon', age: 12 })
        stub_request(:get, 'http://users.example.org/users/4').to_return response({ id: 4, name: 'Johnny', age: 42 })
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
          expect(proc).to receive(:call) do |users|
            expect(users).to be === @users
            expect(users.size).to be == 2
            expect(users).to be_loaded
          end

          @users = model.find 1, 2, &proc
          Acfs.run
        end

        it 'should invoke multiple callback after all models are loaded' do
          proc1 = Proc.new { }
          proc2 = Proc.new { }
          expect(proc1).to receive(:call) do |users|
            expect(users).to be === @users
            expect(users.size).to be == 2
            expect(users).to be_loaded
          end
          expect(proc2).to receive(:call) do |users|
            expect(users).to be === @users
            expect(users.size).to be == 2
            expect(users).to be_loaded
          end

          @users = model.find 1, 2, &proc1
          Acfs.add_callback(@users, &proc2)
          Acfs.run
        end

        it 'should respect resource type inheritance' do
          customers = MyUser.find 3, 4
          Acfs.run

          expect(customers[0]).to be_a Customer
          expect(customers[1]).to be_a MyUser
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

    it 'should invoke multiple callback after all models are loaded' do
      proc1 = Proc.new { }
      proc2 = Proc.new { }
      expect(proc1).to receive(:call) do |computers|
        expect(computers).to be === @computers
        expect(computers.size).to be == 3
        expect(computers).to be_loaded
      end
      expect(proc2).to receive(:call) do |computers|
        expect(computers).to be === @computers
        expect(computers.size).to be == 3
        expect(computers).to be_loaded
      end

      @computers = computer.all &proc1
      Acfs.add_callback(@computers, &proc2)
      Acfs.run
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

      context 'with invalid type set' do
        shared_examples 'with invalid type' do
          it 'should raise error if type is no subclass' do
            Computer.all
            expect { Acfs.run }.to raise_error(Acfs::ResourceTypeError)
          end
        end

        context 'with another resource as type instead' do
          before do
            stub_request(:get, 'http://computers.example.org/computers').to_return response([{ id: 1, type: 'MyUser' }, { id: 2, type: 'Computer' }, { id: 3, type: 'Mac' }])
          end
          it_behaves_like 'with invalid type'
        end

        context 'with a random string as type instead' do
          before do
            stub_request(:get, 'http://computers.example.org/computers').to_return response([{ id: 1, type: 'PC' }, { id: 2, type: 'noValidType' }, { id: 3, type: 'Mac' }])
          end
          it_behaves_like 'with invalid type'
        end

        context 'with a non-string as type instead' do
          before do
            stub_request(:get, 'http://computers.example.org/computers').to_return response([{ id: 1, type: 'PC' }, { id: 2, type: 'Computer' }, { id: 3, type: 42 }])
          end
          it_behaves_like 'with invalid type'
        end
      end
    end
  end

  shared_examples 'find_by' do
    context 'standard resource' do
      let(:model) { MyUser }
      let!(:user) { model.send described_method, age: 24 }
      subject { Acfs.run; user }

      context 'return value' do
        subject { user }

        it { should be_a MyUser }
        it { should_not be_loaded }
      end

      context 'with params' do
        let!(:request) { stub_request(:get, 'http://users.example.org/users?age=24').to_return response([{id: 1, name: 'Mike', age: 24}]) }

        it 'should include params in URI to index action' do
          subject
          expect(request).to have_been_requested
        end
      end

      context 'with non-empty response' do
        before { stub_request(:get, 'http://users.example.org/users?age=24').to_return response([{id: 1, name: 'Mike', age: 24}, {id: 4, type: 'Maria', age: 24}, {id: 7, type: 'James', age: 24}]) }

        it 'should invoke callback after model is loaded' do
          proc = Proc.new { }

          expect(proc).to receive(:call) do |user|
            expect(user).to eql @user.__getobj__
            expect(user).to be_a MyUser
            expect(user).to be_loaded
          end

          @user = model.send described_method, age: 24, &proc
          Acfs.run
        end

        it 'should invoke multiple callbacks after model is loaded' do
          proc1 = Proc.new { }
          proc2 = Proc.new { }

          expect(proc1).to receive(:call) do |user|
            expect(user).to eql @user.__getobj__
            expect(user).to be_a MyUser
            expect(user).to be_loaded
          end

          expect(proc2).to receive(:call) do |user|
            expect(user).to eql @user.__getobj__
            expect(user).to be_a MyUser
            expect(user).to be_loaded
          end

          @user = model.send described_method, age: 24, &proc1
          Acfs.add_callback @user, &proc2
          Acfs.run
        end

        it 'should load a single MyUser object' do
          expect(subject).to be_a MyUser
        end
      end
    end

    context 'singleton resource' do
      let(:model) { Single }

      it '.find_by should not be defined' do
        expect{ model.find_by }.to raise_error NoMethodError
      end
    end
  end

  describe '.find_by' do
    let(:described_method) { :find_by }
    it_behaves_like 'find_by'

    context 'standard resource' do
      let(:model){ MyUser }
      let!(:user) { model.send described_method, age: 24 }
      subject { Acfs.run; user }

      context 'with empty response' do
        before { stub_request(:get, 'http://users.example.org/users?age=24').to_return response([]) }

        it { should be_nil }

        it 'should invoke callback after model is loaded' do
          proc = Proc.new { }

          expect(proc).to receive(:call) do |user|
            expect(user).to eql @user.__getobj__
            expect(user).to be_a NilClass
          end

          @user = model.find_by age: 24, &proc
          Acfs.run
        end

        it 'should invoke multiple callbacks after model is loaded' do
          proc1 = Proc.new { }
          proc2 = Proc.new { }

          expect(proc1).to receive(:call) do |user|
            expect(user).to eql @user.__getobj__
            expect(user).to be_a NilClass
          end
          expect(proc2).to receive(:call) do |user|
            expect(user).to eql @user.__getobj__
            expect(user).to be_a NilClass
          end

          @user = model.find_by age: 24, &proc1
          Acfs.add_callback @user, &proc2
          Acfs.run
        end
      end
    end
  end

  describe '.find_by!' do
    let(:described_method) { :find_by! }
    it_behaves_like 'find_by'

    context 'standard resource' do
      let(:model){ MyUser }
      let!(:user) { model.send described_method, age: 24 }
      subject { Acfs.run; user }

      context 'with empty response' do
        before { stub_request(:get, 'http://users.example.org/users?age=24').to_return response([]) }

        it 'should raise an ResourceNotFound error' do
          model.find_by! age: 24
          expect{ Acfs.run }.to raise_error Acfs::ResourceNotFound
        end

        it 'should not invoke callback after model could not be loaded' do
          proc = Proc.new { }

          expect(proc).not_to receive(:call)

          model.find_by! age: 24, &proc
          expect{ Acfs.run }.to raise_error
        end
      end
    end
  end
end
