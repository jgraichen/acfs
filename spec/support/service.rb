
Acfs.configure do
  locate :user_service, 'http://users.example.org'
  locate :computer_service, 'http://computers.example.org'
  locate :comments, 'http://comments.example.org'
end

class UserService < Acfs::Service
  use Acfs::Middleware::MessagePackDecoder
  use Acfs::Middleware::JsonDecoder
  use Acfs::Middleware::JsonEncoder
end

class CommentService < Acfs::Service
  identity :comments

  use Acfs::Middleware::JsonDecoder
end

class MyUser < Acfs::Resource
  service UserService, path: 'users'

  attribute :id, :integer
  attribute :name, :string, default: 'Anon'
  attribute :age, :integer
end

class Profile < Acfs::SingletonResource
  service UserService, path: 'users/:user_id/profile'

  attribute :user_id, :integer
  attribute :twitter_handle, :string
end

class Customer < MyUser

end

class MyUserWithValidations < MyUser
  validates_presence_of :name, :age
  validates_format_of :name, with: /\A\w+\s+\w+.?\z/
end

class Session < Acfs::Resource
  service UserService, path: {
      list: 'users/:user_id/sessions',
      delete: 'users/:user_id/sessions/del/:id',
      update: nil
  }

  attribute :id, :string
  attribute :user, :integer
end

class Comment < Acfs::Resource
  service CommentService

  attribute :id, :integer
  attribute :text, :string
end

class ComputerService < Acfs::Service
  use Acfs::Middleware::MessagePackDecoder
  use Acfs::Middleware::JsonDecoder
  use Acfs::Middleware::JsonEncoder
end

class Computer < Acfs::Resource
  service ComputerService, path: 'computers'

  attribute :id, :integer
end

class PC < Computer

end

class Mac < Computer

end

class Single < Acfs::SingletonResource
  service UserService

  attribute :score, :integer
  attribute :user_id, :integer
end

# DRAFT: Singular resource
#class Singular < Acfs::Resource
#  service UserService, singular: true
#
#  attribute :name, :string
#end
