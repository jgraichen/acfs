require 'spec_helper'

describe 'Acfs' do

  before do
    stub_request(:get, 'http://users.example.org/users').to_return response([{ id: 1, name: 'Anon', age: 12 }, { id: 2, name: 'John', age: 26 }])
    stub_request(:get, 'http://users.example.org/users/2').to_return response({ id: 2, name: 'John', age: 26 })
    stub_request(:get, 'http://users.example.org/users/3').to_return response({ id: 3, name: 'Miraculix', age: 122 })
    stub_request(:get, 'http://users.example.org/users/100').to_return response({ id:100, name: 'Jimmy', age: 45 })
    stub_request(:get, 'http://users.example.org/users/2/friends').to_return response([{ id: 1, name: 'Anon', age: 12 }])
    stub_request(:get, 'http://users.example.org/singles?user_id=5').to_return response({ score: 250, user_id: 5 })
    stub_request(:get, 'http://comments.example.org/comments?user=2').to_return response([{ id: 1, text: 'Comment #1' }, { id: 2, text: 'Comment #2' }])
  end

  it 'should update single resource synchronously' do
    stub = stub_request(:put, 'http://users.example.org/users/2')
      .to_return { |request| { body: request.body, headers: {'Content-Type' => request.headers['Content-Type']}} }

    @user = MyUser.find 2
    Acfs.run

    expect(@user).to_not be_changed
    expect(@user).to be_persisted

    @user.name = 'Johnny'

    expect(@user).to be_changed
    expect(@user).to_not be_persisted

    @user.save

    expect(stub).to have_been_requested
    expect(@user).to_not be_changed
    expect(@user).to be_persisted
  end

  it 'should create a single resource synchronously' do
    stub = stub_request(:post, 'http://users.example.org/sessions').to_return response({id: 'sessionhash', user: 1})

    session = Session.create ident: 'Anon'

    expect(stub).to have_been_requested
    expect(session.id).to be == 'sessionhash'
    expect(session.user).to be == 1
  end

  it 'should load single resource' do
    @user = MyUser.find(2)

    expect(@user).to_not be_loaded

    Acfs.run

    expect(@user).to be_loaded
    expect(@user.id).to be == 2
    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26
  end

  it 'should load singleton resource' do
    @single = Single.find params: {user_id: 5}
    Acfs.run

    expect(@single.score).to eq 250
  end

  it 'should load multiple single resources' do
    @users = MyUser.find(2, 3, 100) do |users|
      # This block should be called only after *all* resources are loaded.
      @john = users[0]
      @mirx = users[1]
      @jimy = users[2]
    end

    expect(@users).to_not be_loaded

    Acfs.run

    expect(@users).to be_loaded
    expect(@users).to have(3).items

    expect(@users[0].id).to be == 2
    expect(@users[0].name).to be == 'John'
    expect(@users[0].age).to be == 26
    expect(@users[0]).to be == @john

    expect(@users[1].id).to be == 3
    expect(@users[1].name).to be == 'Miraculix'
    expect(@users[1].age).to be == 122
    expect(@users[1]).to be == @mirx

    expect(@users[2].id).to be == 100
    expect(@users[2].name).to be == 'Jimmy'
    expect(@users[2].age).to be == 45
    expect(@users[2]).to be == @jimy
  end

  it 'should load multiple resources' do
    @users = MyUser.all

    expect(@users).to_not be_loaded

    Acfs.run

    expect(@users).to be_loaded
    expect(@users).to have(2).items
    expect(@users[0].name).to be == 'Anon'
    expect(@users[0].age).to be == 12
    expect(@users[1].name).to be == 'John'
    expect(@users[1].age).to be == 26
  end

  it 'should load associated resources' do
    pending 'TODO: Implement high level feature'

    @user = MyUser.find(2) do |user|
      @friends = user.friends.all
    end

    Acfs.run

    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26

    expect(@friends).to have(1).items
  end

  it 'should load associated resources from different service' do
    @user = MyUser.find 2 do |user|
      expect(user.id).to be == 2
      @comments = Comment.where user: user.id
    end

    Acfs.run

    expect(@user.id).to be == 2
    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26

    expect(@comments).to have(2).items
  end
end
