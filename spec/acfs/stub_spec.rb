require 'spec_helper'

class SpecialCustomError < StandardError; end

describe Acfs::Stub do
  let(:stub) { Class.new(Acfs::Stub) }

  before(:all) { Acfs::Stub.enable }
  after(:all) { Acfs::Stub.disable }

  before do
    Acfs::Stub.allow_requests = false
  end

  describe '#called?' do
    context 'without specified number' do
      let!(:operation) { Acfs::Stub.resource MyUser, :read, with: {id: 1}, return: {id: 1, name: 'John Smith', age: 32} }

      it 'should allow to test if stub was called' do
        MyUser.find 1
        Acfs.run

        expect(operation).to be_called
      end

      it 'should allow to test if stub was called a specific number of times' do
        MyUser.find 1
        Acfs.run

        MyUser.find 1
        Acfs.run

        expect(operation).to be_called 2.times
      end
    end
  end

  describe '.resource' do
    context 'with ambiguous stubs' do
      before do
        Acfs::Stub.resource MyUser, :read, with: {id: 1}, return: {id: 1, name: 'John Smith', age: 32}
        Acfs::Stub.resource MyUser, :read, with: {id: 1}, raise: :not_found
      end

      it 'should raise error' do
        MyUser.find 1

        expect { Acfs.run }.to raise_error(Acfs::AmbiguousStubError)
      end
    end

    context 'with read action' do
      before do
        Acfs::Stub.resource MyUser, :read, with: {id: 1}, return: {id: 1, name: 'John Smith', age: 32}
        Acfs::Stub.resource MyUser, :read, with: {id: 2}, raise: SpecialCustomError
        Acfs::Stub.resource MyUser, :read, with: {id: 3}, raise: :not_found
      end

      it 'should allow to stub resource reads' do
        user = MyUser.find 1
        Acfs.run

        expect(user.id).to be == 1
        expect(user.name).to be == 'John Smith'
        expect(user.age).to be == 32
      end

      context 'with error' do
        it 'should allow to raise errors' do
          MyUser.find 2

          expect { Acfs.run }.to raise_error(SpecialCustomError)
        end

        it 'should allow to raise symbolic errors' do
          MyUser.find 3

          expect { Acfs.run }.to raise_error(Acfs::ResourceNotFound)
        end
      end

      context 'with type parameter' do
        before do
          Acfs::Stub.resource Computer, :read, with: {id: 1}, return: {id: 1, type: 'PC'}
          Acfs::Stub.resource Computer, :read, with: {id: 2}, return: {id: 2, type: 'Mac'}
        end

        it 'should create inherited type' do
          pc = Computer.find 1
          mac = Computer.find 2

          Acfs.run

          expect(pc).to be_a PC
          expect(mac).to be_a Mac
        end
      end
    end

    context 'with create action' do
      before do
        Acfs::Stub.resource Session, :create, with: {ident: 'john@exmaple.org', password: 's3cr3t'}, return: {id: 'longhash', user: 1}
        Acfs::Stub.resource Session, :create, with: ->(op) { op.data[:ident] == 'john@exmaple.org' && op.data[:password] == 'wrong' }, raise: 422
      end

      it 'should allow stub resource creation' do
        session = Session.create! ident: 'john@exmaple.org', password: 's3cr3t'

        expect(session.id).to be == 'longhash'
        expect(session.user).to be == 1
      end

      it 'should allow to raise error' do
        expect do
          Session.create! ident: 'john@exmaple.org', password: 'wrong'
        end.to raise_error(::Acfs::InvalidResource)
      end
    end

    context 'with list action' do
      before do
        Acfs::Stub.resource MyUser, :list,
          return: [{id: 1, name: 'John Smith', age: 32}, {id: 2, name: 'Anon', age: 12}]
      end

      it 'should return collection' do
        users = MyUser.all
        Acfs.run

        expect(users).to have(2).items
      end

      it 'should return defined resources' do
        users = MyUser.all
        Acfs.run

        expect(users[0].id).to eq 1
        expect(users[1].id).to eq 2
        expect(users[0].name).to eq 'John Smith'
        expect(users[1].name).to eq 'Anon'
      end

      context 'with type parameter' do
        before do
          Acfs::Stub.resource Computer, :list,
            return: [{id: 1, type: 'PC'}, {id: 2, type: 'Mac'}]
        end

        it 'should create inherited type' do
          computers = Computer.all
          Acfs.run

          expect(computers.first).to be_a PC
          expect(computers.last).to be_a Mac
        end
      end

      context 'with header' do
        before do
          Acfs::Stub.resource Comment, :list,
            return: [{id: 1, text: 'Foo'}, {id: 2, text: 'Bar'}],
            headers: headers
        end

        let!(:comments) { Comment.all }
        let(:headers) { {'X-Total-Pages' => '2'} }
        subject { Acfs.run; comments }

        its(:total_pages) { should eq 2 }
      end
    end

    context 'with update action' do
      before do
        Acfs::Stub.resource MyUser, :read, with: {id: 1}, return: {id: 1, name: 'John Smith', age: 32}
        Acfs::Stub.resource MyUser, :update, with: {id: 1, name: 'John Smith', age: 22}, return: {id: 1, name: 'John Smith', age: 23}
        Acfs::Stub.resource MyUser, :update, with: {id: 1, name: 'John Smith', age: 0}, raise: 422
      end

      it 'should allow stub resource update' do
        user = MyUser.find 1
        Acfs.run

        user.age = 22
        user.save!

        expect(user.age).to be == 23
      end

      it 'should allow to raise error' do
        user = MyUser.find 1
        Acfs.run

        user.age = 0
        user.save

        expect do
          user.save!
        end.to raise_error(::Acfs::InvalidResource)
      end
    end

    context 'with create action' do
      before do
        Acfs::Stub.resource MyUser, :create, with: {name: 'John Smith', age: 0}, raise: 422
      end

      it 'should allow to raise error' do
        expect do
          user = MyUser.create! name: 'John Smith', age: 0
        end.to raise_error(::Acfs::InvalidResource)
      end
    end
  end

  describe '.allow_requests=' do
    context 'when enabled' do
      before do
        Acfs::Stub.allow_requests = true
        stub_request(:get, 'http://users.example.org/users/2').to_return response(id: 2, name: 'John', age: 26)
      end

      it 'should allow real requests' do
        @user = MyUser.find 2
        expect { Acfs.run }.to_not raise_error
      end
    end

    context 'when disabled' do
      before do
        Acfs::Stub.allow_requests = false
      end

      it 'should not allow real requests' do
        @user = MyUser.find 2
        expect { Acfs.run }.to raise_error(Acfs::RealRequestsNotAllowedError)
      end
    end
  end
end
