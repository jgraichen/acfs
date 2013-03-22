require 'spec_helper'

describe "Acfs" do
  let(:user_service) { UserService.new(base_url: 'http://users.example.com') }
  let(:comment_service) { CommentService.new(base_url: 'http://comments.example.com') }

  before do
    Acfs.use Acfs::Middleware::JsonDecoder

    headers = { 'Content-Type' => 'application/json' }
    stub_request(:get, "http://users.example.com/users").to_return(:body => '[{"id":1,"name":"Anon","age":12},{"id":2,"name":"John","age":26}]', headers: headers)
    stub_request(:get, "http://users.example.com/users/2").to_return(:body => '{"id":2,"name":"John","age":26}', headers: headers)
    stub_request(:get, "http://users.example.com/users/2/friends").to_return(:body => '[{"id":1,"name":"Anon","age":12}]', headers: headers)
    stub_request(:get, "http://comments.example.com/comments?user=2").to_return(:body => '[{"id":1,"text":"Comment #1"},{"id":2,"text":"Comment #2"}]', headers: headers)
  end

  #it 'should return proxy objects until loaded' do
  #  @user = user_service.users.find(2)
  #
  #  expect(@user).to_not be_loaded
  #end

  it 'should load single resource' do
    @user = user_service.users.find(2)

    Acfs.run

    #expect(@user).to be_loaded
    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26
  end

  it 'should load multiple resources' do
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

    @user = user_service.users.find(2) do |user|
      @friends = user.friends.all
    end

    Acfs.run

    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26

    expect(@friends).to have(1).items
  end

  it 'should load associated resources from different service' do
    pending "TODO: Implement high level feature"

    @user = user_service.users.find(2) do |user|
      @comments = comment_service.comments.find user: user.id
    end

    Acfs.run

    expect(@user.name).to be == 'John'
    expect(@user.age).to be == 26

    expect(@comments).to have(2).items
  end
end
