# Acfs - *API client for services*

[![Gem Version](https://img.shields.io/gem/v/acfs?logo=ruby)](https://rubygems.org/gems/acfs)
[![Build Status](https://img.shields.io/travis/jgraichen/acfs/master?logo=travis)](https://travis-ci.org/jgraichen/acfs)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/jgraichen/acfs/Test/master?logo=github)](https://github.com/jgraichen/acfs/actions?query=branch%3Amaster)
[![Coverage Status](http://img.shields.io/coveralls/jgraichen/acfs/master.svg)](https://coveralls.io/r/jgraichen/acfs)
[![RubyDoc Documentation](http://img.shields.io/badge/rubydoc-here-blue.svg)](http://rubydoc.info/github/jgraichen/acfs/master/frames)

Acfs is a library to develop API client libraries for single services within a larger service oriented application.

Acfs covers model and service abstraction, convenient query and filter methods, full middleware stack for pre-processing requests and responses on a per service level and automatic request queuing and parallel processing. See Usage for more.


## Installation

Add this line to your application's Gemfile:

    gem 'acfs', '~> 1.3'

And then execute:

    > bundle

Or install it yourself as:

    > gem install acfs


## Usage

First you need to define your service(s):

```ruby
class UserService < Acfs::Service
  self.base_url = 'http://users.myapp.org'

  # You can configure middlewares you want to use for the service here.
  # Each service has it own middleware stack.
  #
  use Acfs::Middleware::JsonDecoder
  use Acfs::Middleware::MessagePackDecoder
end
```

This specifies where the `UserService` is located. You can now create some models representing resources served by the `UserService`.

```ruby
class User < Acfs::Resource
  service UserService # Associate `User` model with `UserService`.

  # Define model attributes and types
  # Types are needed to parse and generate request and response payload.

  attribute :id, :uuid # Types can be classes or symbols.
                       # Symbols will be used to load a class from `Acfs::Model::Attributes` namespace.
                       # Eg. `:uuid` will load class `Acfs::Model::Attributes::Uuid`.

  attribute :name, :string, default: 'Anonymous'
  attribute :age, ::Acfs::Model::Attributes::Integer # Or use :integer

end
```

The service and model classes can be shipped as a gem or git submodule to be included by the frontend application(s).

You can use the model there:

```ruby
@user = User.find 14

@user.loaded? #=> false

Acfs.run # This will run all queued request as parallel as possible.
         # For @user the following URL will be requested:
         # `http://users.myapp.org/users/14`

@model.name # => "..."

@users = User.all
@users.loaded? #=> false

Acfs.run # Will request `http://users.myapp.org/users`

@users #=> [<User>, ...]
```

If you need multiple resources or dependent resources first define a "plan" how they can be loaded:

```ruby
@user = User.find(5) do |user|
  # Block will be executed right after user with id 5 is loaded

  # You can load additional resources also from other services
  # Eg. fetch comments from `CommentSerivce`. The line below will
  # load comments from `http://comments.myapp.org/comments?user=5`
  @comments = Comment.where user: user.id

  # You can load multiple resources in parallel if you have multiple
  # ids.
  @friends  = User.find 1, 4, 10 do |friends|
    # This block will be executed when all friends are loaded.
    # [ ... ]
  end
end

Acfs.run # This call will fire all request as parallel as possible.
         # The sequence above would look similar to:
         #
         # Start                Fin
         #   |===================|       `Acfs.run`
         #   |====|                      /users/5
         #   |    |==============|       /comments?user=5
         #   |    |======|               /users/1
         #   |    |=======|              /users/4
         #   |    |======|               /users/10

# Now we can access all resources:

@user.name       # => "John
@comments.size   # => 25
@friends[0].name # => "Miraculix"
```

Use `.find_by` to get first element only. `.find_by` will call the `index`-Action and return the first resource. Optionally passed params will be sent as `GET` parameters and can be used for filtering in the service's controller.
```ruby
@user = User.find_by age: 24

Acfs.run # Will request `http://users.myapp.org/users?age=24`

@user # Contains the first user object returned by the index action
```
If no object can be found, `.find_by` will return `nil`. The optional callback will then be called with `nil` as parameter. Use `.find_by!` to raise an `Acfs::ResourceNotFound` exception if no object can be found. `.find_by!` will only invoke the optional callback if an object was successfully loaded.

Acfs has basic update support using `PUT` requests:

```ruby
@user = User.find 5
@user.name = "Bob"

@user.changed? # => true
@user.persisted? # => false

@user.save # Or .save!
           # Will PUT new resource to service synchronously.

@user.changed? # => false
@user.persisted? # => true
```


## Singleton resources

Singletons can be used in Acfs by creating a new resource which inherits from `SingletonResource`:

```ruby
class Single < Acfs::SingletonResource
  service UserService # Associate `Single` model with `UserService`.

  # Define model attributes and types as with regular resources

  attribute :name, :string, default: 'Anonymous'
  attribute :age, :integer

end
```

The following code explains the routing for singleton resource requests:

```ruby
my_single = Single.new
mysingle.save # sends POST request to /single

my_single = Single.find
Acfs.run # sends GET request to /single

my_single.age = 28
my_single.save # sends PUT request to /single

my_single.delete # sends DELETE request to /single
```

You also can pass parameters to the find call, these will sent as GET params to the index action:

```ruby
my_single = Single.find name: 'Max'
Acfs.run # sends GET request with param to /single?name=Max
```


## Resource Inheritance

Acfs provides a resource inheritance similar to ActiveRecord Single Table Inheritance. If a
`type` attribute exists and is a valid subclass of your resource they will be converted
to you subclassed resources:

```ruby
class Computer < Acfs::Resource
  ...
end

class Pc < Computer end
class Mac < Computer end
```

With the following response on `GET /computers` the collection will contain the appropriate
subclass resources:

```json
[
    { "id": 5, "type": "Computer"},
    { "id": 6, "type": "Mac"},
    { "id": 8, "type": "Pc"}
]
```

```ruby
@computers = Computer.all

Acfs.run

@computer[0].class # => Computer
@computer[1].class # => Mac
@computer[2].class # => Pc
```


## Stubbing

You can stub resources in applications using an Acfs service client:

```ruby
# spec_helper.rb

# This will enable stabs before each spec and clear internal state
# after each spec.
require 'acfs/rspec'
```

```ruby
before do
  @stub = Acfs::Stub.resource MyUser, :read, with: { id: 1 }, return: { id: 1, name: 'John Smith', age: 32 }
  Acfs::Stub.resource MyUser, :read, with: { id: 2 }, raise: :not_found
  Acfs::Stub.resource Session, :create, with: { ident: 'john@exmaple.org', password: 's3cr3t' }, return: { id: 'longhash', user: 1 }
  Acfs::Stub.resource MyUser, :update, with: lambda { |op| op.data.include? :my_var }, raise: 400
end

it 'should find user number one' do
  user = MyUser.find 1
  Acfs.run

  expect(user.id).to be == 1
  expect(user.name).to be == 'John Smith'
  expect(user.age).to be == 32

  expect(@stub).to be_called
  expect(@stub).to_not be_called 5.times
end

it 'should not find user number two' do
  MyUser.find 3

  expect { Acfs.run }.to raise_error(Acfs::ResourceNotFound)
end

it 'should allow stub resource creation' do
  session = Session.create! ident: 'john@exmaple.org', password: 's3cr3t'

  expect(session.id).to be == 'longhash'
  expect(session.user).to be == 1
end
```

By default Acfs raises an error when a non stubbed resource should be requested. You can switch of the behavior:

```ruby
before do
  Acfs::Stub.allow_requests = true
end

it 'should find user number one' do
  user = MyUser.find 1
  Acfs.run             # Would have raised Acfs::RealRequestNotAllowedError
                       # Will run real request to user service instead.
end
```


## Instrumentation

Acfs supports [instrumentation via active support][1].

Acfs expose to following events

* `acfs.operation.complete(operation, response)`: Acfs operation completed
* `acfs.runner.sync_run(operation)`: Run operation right now skipping queue.
* `acfs.runner.enqueue(operation)`: Enqueue operation to be run later.
* `acfs.before_run`: directly before `acfs.run`
* `acfs.run`: Run all queued operations.

Read [official guide][2] to see to to subscribe.

[1]: http://guides.rubyonrails.org/active_support_instrumentation.html
[2]: http://guides.rubyonrails.org/active_support_instrumentation.html#subscribing-to-an-event


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
4. Add specs for your feature
5. Implement your feature
6. Commit your changes (`git commit -am 'Add some feature'`)
7. Push to the branch (`git push origin my-new-feature`)
8. Create new Pull Request


## License

MIT License

Copyright (c) 2013-2020 Jan Graichen. MIT license, see LICENSE for more details.
