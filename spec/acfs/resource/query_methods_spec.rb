require 'spec_helper'

describe Acfs::Resource::QueryMethods do
  let(:model) { MyUser }

  describe '.find' do
    context 'with single id' do
      context 'with successful response' do
        before do
          stub_request(:get, 'http://users.example.org/users/1')
            .to_return response id: 1, name: 'Anon', age: 12, born_at: 'Berlin'
          stub_request(:get, 'http://users.example.org/users/2')
            .to_return response id: 2, type: 'Customer',
                                name: 'Clare Customer', age: 24
        end

        let(:action) { ->(cb = nil) { model.find(1, &cb) } }
        it_behaves_like 'a query method with multi-callback support'

        it 'should load a single remote resource' do
          user = action.call
          Acfs.run

          expect(user.attributes).to eq id: 1, name: 'Anon',
                                        age: 12, born_at: 'Berlin'
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
          stub_request(:get, 'http://users.example.org/users/1')
            .to_return response({error: 'not found'}, {status: 404})
        end

        it 'should raise a NotFound error' do
          @user = model.find 1

          expect { Acfs.run }.to raise_error(Acfs::ResourceNotFound)

          expect(@user).to_not be_loaded
        end
      end

      context 'with 500 response' do
        before do
          stub_request(:get, 'http://users.example.org/users/1')
            .to_return response(nil, status: 500)
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
        stub_request(:get, 'http://users.example.org/users/1')
          .to_return response id: 1, name: 'Anon', age: 12
        stub_request(:get, 'http://users.example.org/users/2')
          .to_return response id: 2, name: 'Johnny', age: 42
        stub_request(:get, 'http://users.example.org/users/3')
          .to_return response id: 3, type: 'Customer', name: 'Anon', age: 12
        stub_request(:get, 'http://users.example.org/users/4')
          .to_return response id: 4, name: 'Johnny', age: 42
      end

      context 'with successful response' do
        it 'should load a multiple remote resources' do
          users = model.find([1, 2])
          Acfs.run

          expect(users.size).to be == 2
          expect(users[0].attributes).to eq id: 1, name: 'Anon', age: 12
          expect(users[1].attributes).to eq id: 2, name: 'Johnny', age: 42
        end

        it 'should invoke callback after all models are loaded' do
          block = proc {}
          expect(block).to receive(:call) do |users|
            expect(users).to equal @users
            expect(users.size).to be == 2
            expect(users).to be_loaded
          end

          @users = model.find([1, 2], &block)
          Acfs.run
        end

        it 'should invoke multiple callback after all models are loaded' do
          proc1 = proc {}
          proc2 = proc {}
          expect(proc1).to receive(:call) do |users|
            expect(users).to equal @users
            expect(users.size).to be == 2
            expect(users).to be_loaded
          end
          expect(proc2).to receive(:call) do |users|
            expect(users).to equal @users
            expect(users.size).to be == 2
            expect(users).to be_loaded
          end

          @users = model.find([1, 2], &proc1)
          Acfs.add_callback(@users, &proc2)
          Acfs.run
        end

        it 'should respect resource type inheritance' do
          customers = MyUser.find [3, 4]
          Acfs.run

          expect(customers[0]).to be_a Customer
          expect(customers[1]).to be_a MyUser
        end
      end

      context 'with one 404 response' do
        before do
          stub_request(:get, 'http://users.example.org/users/1')
            .to_return response({error: 'not found'}, {status: 404})
        end

        it 'should raise resource not found error' do
          model.find [1, 2]

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
      stub_request(:get, 'http://computers.example.org/computers')
        .to_return response [
          {id: 1, type: 'PC'},
          {id: 2, type: 'Computer'},
          {id: 3, type: 'Mac'}]
    end

    it 'should invoke multiple callback after all models are loaded' do
      proc1 = proc {}
      proc2 = proc {}
      expect(proc1).to receive(:call) do |computers|
        expect(computers).to equal @computers
        expect(computers.size).to be == 3
        expect(computers).to be_loaded
      end
      expect(proc2).to receive(:call) do |computers|
        expect(computers).to equal @computers
        expect(computers.size).to be == 3
        expect(computers).to be_loaded
      end

      @computers = computer.all(&proc1)
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
            stub_request(:get, 'http://computers.example.org/computers')
              .to_return response [
                {id: 1, type: 'MyUser'},
                {id: 2, type: 'Computer'},
                {id: 3, type: 'Mac'}]
          end
          it_behaves_like 'with invalid type'
        end

        context 'with a random string as type instead' do
          before do
            stub_request(:get, 'http://computers.example.org/computers')
              .to_return response [
                {id: 1, type: 'PC'},
                {id: 2, type: 'noValidType'},
                {id: 3, type: 'Mac'}]
          end
          it_behaves_like 'with invalid type'
        end

        context 'with a non-string as type instead' do
          before do
            stub_request(:get, 'http://computers.example.org/computers')
              .to_return response [
                {id: 1, type: 'PC'},
                {id: 2, type: 'Computer'},
                {id: 3, type: 42}]
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
      subject { Acfs.run && user }

      context 'return value' do
        subject { user }

        it { should be_a MyUser }
        it { should_not be_loaded }
      end

      context 'with params' do
        let!(:request) do
          stub_request(:get, 'http://users.example.org/users?age=24')
            .to_return response([{id: 1, name: 'Mike', age: 24}])
        end

        it 'should include params in URI to index action' do
          subject
          expect(request).to have_been_requested
        end
      end

      context 'with non-empty response' do
        before do
          stub_request(:get, 'http://users.example.org/users?age=24')
            .to_return response [
              {id: 1, name: 'Mike', age: 24},
              {id: 4, type: 'Maria', age: 24},
              {id: 7, type: 'James', age: 24}]
        end

        it 'should invoke callback after model is loaded' do
          block = proc {}

          expect(block).to receive(:call) do |user|
            expect(user).to eql @user.__getobj__
            expect(user).to be_a MyUser
            expect(user).to be_loaded
          end

          @user = model.send described_method, age: 24, &block
          Acfs.run
        end

        it 'should invoke multiple callbacks after model is loaded' do
          proc1 = proc {}
          proc2 = proc {}

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
        expect { model.find_by }.to raise_error ::Acfs::UnsupportedOperation
      end
    end
  end

  describe '.find_by' do
    let(:described_method) { :find_by }
    it_behaves_like 'find_by'

    context 'standard resource' do
      let(:model) { MyUser }
      let!(:user) { model.send described_method, age: 24 }
      subject { Acfs.run && user }

      context 'with empty response' do
        before do
          stub_request(:get, 'http://users.example.org/users?age=24')
            .to_return response []
        end

        it { should be_nil }

        it 'should invoke callback after model is loaded' do
          block = proc {}

          expect(block).to receive(:call) do |user|
            expect(user).to eql @user.__getobj__
            expect(user).to be_a NilClass
          end

          @user = model.find_by age: 24, &block
          Acfs.run
        end

        it 'should invoke multiple callbacks after model is loaded' do
          proc1 = proc {}
          proc2 = proc {}

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
      let(:model) { MyUser }
      let!(:user) { model.send described_method, age: 24 }
      subject { Acfs.run && user }

      context 'with empty response' do
        before do
          stub_request(:get, 'http://users.example.org/users?age=24')
            .to_return response []
        end

        it 'should raise an ResourceNotFound error' do
          model.find_by! age: 24
          expect { Acfs.run }.to raise_error Acfs::ResourceNotFound
        end

        it 'should not invoke callback after model could not be loaded' do
          block = proc {}

          expect(block).not_to receive(:call)

          model.find_by! age: 24, &block
          expect { Acfs.run }.to raise_error
        end
      end
    end

    describe '#each_page' do
      context 'without parameters' do
        before do
          stub_request(:get, 'http://users.example.org/users')
            .to_return response([{id: 1, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => '<http://users.example.org/users?page=2>; rel="next"'
              })
          stub_request(:get, 'http://users.example.org/users?page=2')
            .to_return response([{id: 2, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => '<http://users.example.org/users?page=3>; rel="next"'
              })
          stub_request(:get, 'http://users.example.org/users?page=3')
            .to_return response([{id: 3, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => '<http://users.example.org/users?page=4>; rel="next"'
              })
          stub_request(:get, 'http://users.example.org/users?page=4')
            .to_return response([{id: 4, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => ''
              })
        end

        it 'should iterate all pages' do
          index = 0
          model.each_page do |page|
            expect(page).to be_a Acfs::Collection

            index += 1
            expect(page.first.id).to eq index
          end
          Acfs.run

          expect(index).to eq 4
        end
      end

      context 'with parameters' do
        before do
          stub_request(:get, 'http://users.example.org/users?param=bla')
            .to_return response([{id: 1, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => '<http://users.example.org/users?where=fuu&page=2>; rel="next"'
              })
          stub_request(:get, 'http://users.example.org/users?where=fuu&page=2')
            .to_return response([{id: 2, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => '<http://users.example.org/users?page=3>; rel="next"'
              })
          stub_request(:get, 'http://users.example.org/users?page=3')
            .to_return response([{id: 3, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => '<http://users.example.org/users?page=4>; rel="next"'
              })
          stub_request(:get, 'http://users.example.org/users?page=4')
            .to_return response([{id: 4, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => ''
              })
        end

        it 'should call first page with params and follow relations' do
          index = 0
          model.each_page(param: 'bla') do |page|
            expect(page).to be_a Acfs::Collection

            index += 1
            expect(page.first.id).to eq index
          end
          Acfs.run

          expect(index).to eq 4
        end
      end
    end

    describe '#each_item' do
      context 'without parameters' do
        before do
          stub_request(:get, 'http://users.example.org/users')
            .to_return response([{id: 1, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => '<http://users.example.org/users?page=2>; rel="next"'
              })
          stub_request(:get, 'http://users.example.org/users?page=2')
            .to_return response([{id: 2, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => '<http://users.example.org/users?page=3>; rel="next"'
              })
          stub_request(:get, 'http://users.example.org/users?page=3')
            .to_return response([{id: 3, name: 'Anno', age: 1604, born_at: 'Santa Maria'}, {id: 4, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => '<http://users.example.org/users?page=4>; rel="next"'
              })
          stub_request(:get, 'http://users.example.org/users?page=4')
            .to_return response([{id: 5, name: 'Anno', age: 1604, born_at: 'Santa Maria'}],
              headers: {
                'X-Total-Pages' => '4',
                'Link'          => ''
              })
        end

        it 'should iterate all pages' do
          indecies = []
          model.each_item do |item|
            expect(item).to be_a MyUser
            indecies << item.id
          end
          Acfs.run

          expect(indecies).to eq [1, 2, 3, 4, 5]
        end

        it 'should pass the collection to the provided block' do
          model.each_item do |_item, collection|
            expect(collection).to be_a Acfs::Collection
          end
          Acfs.run
        end
      end
    end
  end
end
