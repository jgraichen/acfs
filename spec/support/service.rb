
class UserService < Acfs::Service
  self.base_url = 'http://users.example.org'
end

class CommentService < Acfs::Service
  self.base_url = 'http://comments.example.org'
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

  attribute :text, :string
end
