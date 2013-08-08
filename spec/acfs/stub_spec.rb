require 'spec_helper'

class SpecialCustomError < StandardError; end

describe Acfs::Stub do
  let(:stub) { Class.new(Acfs::Stub) }

  before(:all) { Acfs::Stub.enable }
  after(:all) { Acfs::Stub.disable }

  before do
    Acfs::Stub.allow_requests = false

    #Acfs::Stub.read(MyUser).with(id: 5).and_return({ id: 5, name: 'John', age: 32 })
    #Acfs::Stub.read(MyUser).with(id: 6).and_raise(:not_found)
    #Acfs::Stub.create(MyUser).with(name: '', age: 12).and_return(:invalid, errors: { name: [ 'must be present ']})
  end

  describe '.resource' do
    context 'with read action' do
      before do
        Acfs::Stub.resource MyUser, :read, with: { id: 1 }, return: { id: 1, name: 'John Smith', age: 32 }
        Acfs::Stub.resource MyUser, :read, with: { id: 2 }, raise: SpecialCustomError
        Acfs::Stub.resource MyUser, :read, with: { id: 3 }, raise: :not_found
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
    end

    context 'with create action' do
      before do
        Acfs::Stub.resource Session, :create, with: { ident: 'john@exmaple.org', password: 's3cr3t' }, return: { id: 'longhash', user: 1 }
        Acfs::Stub.resource Session, :create, with: { ident: 'john@exmaple.org', password: 'wrong' }, raise: 422
      end

      it 'should allow stub resource creation' do
        session = Session.create! ident: 'john@exmaple.org', password: 's3cr3t'

        expect(session.id).to be == 'longhash'
        expect(session.user).to be == 1
      end

      it 'should allow to raise error' do
        expect {
          Session.create! ident: 'john@exmaple.org', password: 'wrong'
        }.to raise_error(::Acfs::InvalidResource)
      end
    end

    context 'with update action' do
      before do
        Acfs::Stub.resource MyUser, :read, with: { id: 1 }, return: { id: 1, name: 'John Smith', age: 32 }
        Acfs::Stub.resource MyUser, :update, with: { id: 1, name: 'John Smith', age: 22 }, return: { id: 1, name: 'John Smith', age: 23 }
        Acfs::Stub.resource MyUser, :update, with: { id: 1, name: 'John Smith', age: 0 }, raise: 422
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

        expect {
          user.save!
        }.to raise_error(::Acfs::InvalidResource)
      end
    end
  end

  describe '.allow_requests=' do
    context 'when enabled' do
      before do
        Acfs::Stub.allow_requests = true
        stub_request(:get, 'http://users.example.org/users/2').to_return response({ id: 2, name: 'John', age: 26 })
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
