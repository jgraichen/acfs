require 'spec_helper'

describe "Acfs" do
  let(:client) { MyClient.new(base_url: 'http://api.example.com') }

  before do
    stub_request(:get, "api.example.com/users").with(:body => '[{"id":1,"name":"Anon","age":12},{"id":2,"name":"John","age":26}]')
    stub_request(:get, "api.example.com/users/2").with(:body => '{"id":2,"name":"John","age":26}')
    stub_request(:get, "api.example.com/users/2/comments").with(:body => '[{"id":1,"text":"Comment #1"},{"id":2,"text":"Comment #2"}]')
  end

  it 'should load single resource' do
    pending "TODO: Implement high level feature"

    user = client.users.find 2

    client.run

    exepct(user.name).to be == 'John'
    expect(user.age).to be == 26
  end

  it 'should load single resource (block)' do
    pending "TODO: Implement high level feature"

    client.run do |cl|
      user = cl.users.find 2
    end

    exepct(user.name).to be == 'John'
    expect(user.age).to be == 26
  end

  it 'should load multiple resources' do
    pending "TODO: Implement high level feature"

    users = client.users.all

    client.run

    expect(users).to have(2).items
    expect(users[0].name).to be == 'Anon'
    expect(users[0].age).to be == 12
    expect(users[1].name).to be == 'John'
    expect(users[1].age).to be == 26
  end

  it 'should load associated resources' do
    pending "TODO: Implement high level feature"

    @user = client.user.find(1) do |user|
      @comments = user.comments.all
    end

    client.run

    exepct(@user.name).to be == 'John'
    expect(@user.age).to be == 26

    expect(@comments).to have(2).items
  end
end
