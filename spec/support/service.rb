
class UserService < Acfs::Service
  self.base_url = 'http://users.example.org'
  use Acfs::Middleware::MessagePackDecoder
  use Acfs::Middleware::JsonDecoder
end

class CommentService < Acfs::Service
  self.base_url = 'http://comments.example.org'
  use Acfs::Middleware::JsonDecoder
end

class MyUser
  include Acfs::Model
  service UserService, path: 'users'

  attribute :id, :integer
  attribute :name, :string, default: 'Anon'
  attribute :age, :integer
end

class Comment
  include Acfs::Model
  service CommentService

  attribute :id, :integer
  attribute :text, :string
end
