# Acfs - *API client for services*

[![Gem Version](https://badge.fury.io/rb/acfs.png)](http://badge.fury.io/rb/acfs) [![Build Status](https://travis-ci.org/jgraichen/acfs.png?branch=master)](https://travis-ci.org/jgraichen/acfs) [![Coverage Status](https://coveralls.io/repos/jgraichen/acfs/badge.png?branch=master)](https://coveralls.io/r/jgraichen/acfs) [![Code Climate](https://codeclimate.com/github/jgraichen/acfs.png)](https://codeclimate.com/github/jgraichen/acfs) [![Dependency Status](https://gemnasium.com/jgraichen/acfs.png)](https://gemnasium.com/jgraichen/acfs)

TODO: Develop asynchronous parallel API client library for service oriented applications.

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'acfs', '0.7.0'

**Note:** Acfs is under development. I'll try to avoid changes to the public
API but internal APIs may change quite often.

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acfs

## Usage

First you need to define your service(s):

```ruby
class UserService < Acfs::Service
  self.base_url = 'http://users.myapp.org'

  # You can configure middlewares you want use for the service here.
  # Each service has it own middleware stack.
  #
  use Acfs::Middleware::JsonDecoder
  use Acfs::Middleware::MessagePackDecoder
end
```

This specifies where the `UserService` can be reached. You can now create some
models representing resources serviced by the `UserService`.

```ruby
class User
  include Acfs::Model
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

The service and model classes can be shipped as a gem or git submodule to be
included by the frontend application(s).

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

If you need multiple resources or dependent resources first define a "plan"
how they can be loaded:

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

## TODO

* Create/Update operations
* High level features
    * Pagination? Filtering? (If service API provides such features.)
    * Messaging Queue support for services and models
* Documentation

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

Copyright (c) 2013 Jan Graichen. MIT license, see LICENSE for more details.
