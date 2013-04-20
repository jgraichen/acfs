require 'spec_helper'

describe "Acfs" do

  before do
    headers         = {}
    stub_request(:get, "http://users.example.org/users").to_return(
        body: MessagePack.dump([{ id: 1, name: "Anon", age: 12 }, { id: 2, name: "John", age: 26 }]),
        headers: headers.merge({'Content-Type' => 'application/x-msgpack'}))
    stub_request(:get, "http://users.example.org/users/2").to_return(
        body: MessagePack.dump({ id: 2, name: "John", age: 26 }),
        headers: headers.merge({'Content-Type' => 'application/x-msgpack'}))
    stub_request(:get, "http://users.example.org/users/3").to_return(
        body: MessagePack.dump({ id: 2, name: "Miraculix", age: 122 }),
        headers: headers.merge({'Content-Type' => 'application/x-msgpack'}))
    stub_request(:get, "http://users.example.org/users/100").to_return(
        body: '{"id":2,"name":"Jimmy","age":45}',
        headers: headers.merge({'Content-Type' => 'application/json'}))
    stub_request(:get, "http://users.example.org/users/2/friends").to_return(
        body: '[{"id":1,"name":"Anon","age":12}]',
        headers: headers.merge({'Content-Type' => 'application/json'}))
    stub_request(:get, "http://comments.example.org/comments?user=2").to_return(
        body: '[{"id":1,"text":"Comment #1"},{"id":2,"text":"Comment #2"}]',
        headers: headers.merge({'Content-Type' => 'application/json'}))
  end

  it 'should load single resource' do
    @user = MyUser.find(2)

    expect(@user).to_not be_loaded

    Acfs.run

    expect(@user).to be_loaded
    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26
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

    expect(@users[0].name).to be == 'John'
    expect(@users[0].age).to be == 26
    expect(@users[0]).to be == @john

    expect(@users[1].name).to be == 'Miraculix'
    expect(@users[1].age).to be == 122
    expect(@users[1]).to be == @mirx

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
    pending "TODO: Implement high level feature"

    @user = MyUser.find(2) do |user|
      @friends = user.friends.all
    end

    Acfs.run

    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26

    expect(@friends).to have(1).items
  end

  it 'should load associated resources from different service' do
    @user = MyUser.find(2) do |user|
      @comments = Comment.where user: user.id
    end

    Acfs.run

    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26

    expect(@comments).to have(2).items
  end
end
