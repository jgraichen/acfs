
Acfs.configure do
  locate :user_service, 'http://users.example.org'
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

class MyUserInherited < MyUser

end

class MyUserWithValidations < MyUser
  validates_presence_of :name, :age
  validates_format_of :name, with: /\A\w+\s+\w+.?\z/
end

class Session < Acfs::Resource
  service UserService

  attribute :id, :string
  attribute :user, :integer
end

class Comment < Acfs::Resource
  service CommentService

  attribute :id, :integer
  attribute :text, :string
end
