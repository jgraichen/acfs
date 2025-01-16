# frozen_string_literal: true

require 'spec_helper'

describe 'Acfs' do
  before do
    stub_request(:get, 'http://users.example.org/users')
      .to_return response([{id: 1, name: 'Anon', age: 12}, {id: 2, name: 'John', age: 26}])

    stub_request(:get, 'http://users.example.org/users/2')
      .to_return response(id: 2, name: 'John', age: 26)

    stub_request(:get, 'http://users.example.org/users/3')
      .to_return response(id: 3, name: 'Miraculix', age: 122)

    stub_request(:get, 'http://users.example.org/users/100')
      .to_return response(id: 100, name: 'Jimmy', age: 45)

    stub_request(:get, 'http://users.example.org/users/2/friends')
      .to_return response([{id: 1, name: 'Anon', age: 12}])

    stub_request(:get, 'http://comments.example.org/comments?user=2')
      .to_return response([{id: 1, text: 'Comment #1'}, {id: 2, text: 'Comment #2'}])
  end

  it 'updates single resource synchronously' do
    stub = stub_request(:put, 'http://users.example.org/users/2')
      .to_return {|request| {body: request.body, headers: {'Content-Type' => request.headers['Content-Type']}} }

    user = MyUser.find 2
    Acfs.run

    expect(user).not_to be_changed
    expect(user).to be_persisted

    user.name = 'Johnny'

    expect(user).to be_changed
    expect(user).to be_persisted

    user.save

    expect(stub).to have_been_requested
    expect(user).not_to be_changed
    expect(user).to be_persisted
  end

  it 'creates a single resource synchronously' do
    stub = stub_request(:post, 'http://users.example.org/sessions').to_return response(id: 'sessionhash', user: 1)

    session = Session.create ident: 'Anon'

    expect(stub).to have_been_requested
    expect(session.id).to eq 'sessionhash'
    expect(session.user).to eq 1
  end

  it 'loads single resource' do
    user = MyUser.find(2)

    expect(user).not_to be_loaded

    Acfs.run

    expect(user).to be_loaded
    expect(user.id).to eq 2
    expect(user.name).to eq 'John'
    expect(user.age).to eq 26
  end

  describe 'singleton' do
    before do
      stub_request(:get, 'http://users.example.org/singles?user_id=5').to_return response(score: 250, user_id: 5)
    end

    it 'creates a singleton resource' do
      stub = stub_request(:post, 'http://users.example.org/singles').to_return response(score: 250, user_id: 5)

      single = Single.new user_id: 5, score: 250
      expect(single.new?).to be true

      single.save
      expect(stub).to have_been_requested

      expect(single.new?).to be false
      expect(single.user_id).to eq 5
      expect(single.score).to eq 250
    end

    it 'loads singleton resource' do
      single = Single.find user_id: 5
      Acfs.run

      expect(single.score).to eq 250
    end

    it 'updates singleton resource' do
      stub = stub_request(:put, 'http://users.example.org/singles').to_return do |request|
        {
          body: request.body,
          headers: {'Content-Type' => request.headers['Content-Type']},
        }
      end

      single = Single.find user_id: 5
      Acfs.run

      expect(single.score).to eq 250

      single.score = 300
      single.save

      expect(stub).to have_been_requested

      expect(single.score).to eq 300
    end

    it 'deletes singleton resource' do
      stub = stub_request(:delete, 'http://users.example.org/singles').to_return do |request|
        {
          body: request.body,
          headers: {'Content-Type' => request.headers['Content-Type']},
        }
      end

      single = Single.find user_id: 5
      Acfs.run

      expect(single.new?).to be false

      single.delete

      expect(stub).to have_been_requested
    end

    it 'raises error when calling .all' do
      expect { Single.all }.to raise_error Acfs::UnsupportedOperation
    end
  end

  it 'loads multiple single resources' do
    john = nil
    mirx = nil
    jimy = nil

    users = MyUser.find([2, 3, 100]) do |users|
      # This block should be called only after *all* resources are loaded.
      john = users[0]
      mirx = users[1]
      jimy = users[2]
    end

    expect(users).not_to be_loaded

    Acfs.run

    expect(users).to be_loaded
    expect(users).to have(3).items

    expect(users[0].id).to eq 2
    expect(users[0].name).to eq 'John'
    expect(users[0].age).to eq 26
    expect(users[0]).to eq john

    expect(users[1].id).to eq 3
    expect(users[1].name).to eq 'Miraculix'
    expect(users[1].age).to eq 122
    expect(users[1]).to eq mirx

    expect(users[2].id).to eq 100
    expect(users[2].name).to eq 'Jimmy'
    expect(users[2].age).to eq 45
    expect(users[2]).to eq jimy
  end

  it 'loads multiple resources' do
    users = MyUser.all

    expect(users).not_to be_loaded

    Acfs.run

    expect(users).to be_loaded
    expect(users).to have(2).items
    expect(users[0].name).to eq 'Anon'
    expect(users[0].age).to eq 12
    expect(users[1].name).to eq 'John'
    expect(users[1].age).to eq 26
  end

  it 'loads associated resources' do
    pending 'TODO: Implement high level feature'
    friends = nil

    user = MyUser.find(2) do |user|
      friends = user.friends.all
    end

    Acfs.run

    expect(user.name).to eq 'John'
    expect(user.age).to eq 26

    expect(friends).to have(1).items
  end

  it 'loads associated resources from different service' do
    comments = nil

    user = MyUser.find 2 do |user|
      expect(user.id).to eq 2
      comments = Comment.where({user: user.id})
    end

    Acfs.run

    expect(user.id).to eq 2
    expect(user.name).to eq 'John'
    expect(user.age).to eq 26

    expect(comments).to have(2).items
  end
end
