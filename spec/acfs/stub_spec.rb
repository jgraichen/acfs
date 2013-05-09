require 'spec_helper'

class SpecialCustomError < StandardError; end

describe Acfs::Stub do
  let(:stub) { Class.new(Acfs::Stub) }

  before do
    Acfs::Stub.clear

    #Acfs::Stub.read(MyUser).with(id: 5).and_return({ id: 5, name: 'John', age: 32 })
    #Acfs::Stub.read(MyUser).with(id: 6).and_raise(:not_found)
    #Acfs::Stub.create(MyUser).with(name: '', age: 12).and_return(:invalid, errors: { name: [ 'must be present ']})
  end

  describe '.resource' do
    before do
      Acfs::Stub.resource MyUser, action: :read, with: { id: 1 }, return: { id: 5, name: 'John', age: 32 }
      Acfs::Stub.resource MyUser, action: :read, with: { id: 2 }, raise: SpecialCustomError
      Acfs::Stub.resource MyUser, action: :read, with: { id: 3 }, raise: :not_found
    end

    context 'with read action' do
      it 'should allow to stub resource reads' do
        pending 'Waiting on own operation queue implementation'

        user = MyUser.find 1
        Acfs.run

        expect(user.id).to be == 1
        expect(user.name).to be == 'John Smith'
        expect(user.age).to be == 32
      end

      context 'with error' do
        it 'should allow to raise errors' do
          pending 'Waiting on own operation queue implementation'

          MyUser.find 2

          expect { Acfs.run }.to raise_error(SpecialCustomError)
        end

        it 'should allow to raise symbolic errors' do
          pending 'Waiting on own operation queue implementation'

          MyUser.find 3

          expect { Acfs.run }.to raise_error(Acfs::ResourceNotFound)
        end
      end
    end
  end

  describe '.resource' do

  end
end
