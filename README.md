# Acfs - *API client for services*

[![Gem Version](https://badge.fury.io/rb/acfs.png)](http://badge.fury.io/rb/acfs) [![Build Status](https://travis-ci.org/jgraichen/acfs.png?branch=master)](https://travis-ci.org/jgraichen/acfs) [![Coverage Status](https://coveralls.io/repos/jgraichen/acfs/badge.png?branch=master)](https://coveralls.io/r/jgraichen/acfs) [![Code Climate](https://codeclimate.com/github/jgraichen/acfs.png)](https://codeclimate.com/github/jgraichen/acfs) [![Dependency Status](https://gemnasium.com/jgraichen/acfs.png)](https://gemnasium.com/jgraichen/acfs)

TODO: Develop asynchronous parallel API client library for service oriented applications.

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'acfs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acfs

## Usage

TODO: Write usage instructions here

### Acfs::Attributes

```ruby
class MyModel
  include Acfs::Attributes

  attribute :name, :string
  attribute :age, :integer, default: 15
end

MyModel.attributes # => { "name" => "", "age" => 15 }

mo = MyModel.new name: 'Johnny', age: 12
mo.name # => "Johnny"
mo.age = '13'
mo.age # => 13
mo.attributes # => { "name" => "Johnny", "age" => 13 }

```

## TODO

* Library Code
* Documentation

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add specs for your feature
4. Implement your feature
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request
