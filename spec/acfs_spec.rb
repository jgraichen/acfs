require 'spec_helper'

describe "Acfs" do
  let(:user_service) { UserService.new(base_url: 'http://users.example.com') }
  let(:comment_service) { CommentService.new(base_url: 'http://comments.example.com') }

  before do
    stub_request(:get, "http://users.example.com/users").to_return(:body => '[{"id":1,"name":"Anon","age":12},{"id":2,"name":"John","age":26}]')
    stub_request(:get, "http://users.example.com/users/2").to_return(:body => '{"id":2,"name":"John","age":26}')
    stub_request(:get, "http://users.example.com/users/2/friends").to_return(:body => '[{"id":1,"name":"Anon","age":12}]')
    stub_request(:get, "http://comments.example.com/comments?user=2").to_return(:body => '[{"id":1,"text":"Comment #1"},{"id":2,"text":"Comment #2"}]')
  end

  it 'should load single resource' do
    @user = user_service.users.find(2)

    Acfs.run

    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26
  end

  it 'should load single resource (block)' do
    Acfs.run do
      @user = user_service.users.find 2
    end

    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26
  end

  it 'should load multiple resources' do
    pending "TODO: Implement high level feature"

    @users = user_service.users.all

    Acfs.run

    expect(@users).to have(2).items
    expect(@users[0].name).to be == 'Anon'
    expect(@users[0].age).to be == 12
    expect(@users[1].name).to be == 'John'
    expect(@users[1].age).to be == 26
  end

  it 'should load associated resources' do
    pending "TODO: Implement high level feature"

    @user = user_service.user.find(1) do |user|
      @friends = user.friends.all
    end

    Acfs.run

    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26

    expect(@friends).to have(1).items
  end

  it 'should load associated resources from different service' do
    pending "TODO: Implement high level feature"

    @user = user_service.user.find(1) do |user|
      @comments = comment_service.comments.find user: user.id
    end

    Acfs.run

    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26

    expect(@comments).to have(2).items
  end
end
