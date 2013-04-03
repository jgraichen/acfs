
class UserService < Acfs::Client
  self.base_url = 'http://accounts.acfs'
end

class CommentService < Acfs::Client
  self.base_url = 'http://comments.acfs'
end

class MyUser
  include Acfs::Model
  service UserService

  attribute :id, :integer
  attribute :name, :string, default: 'Anon'
  attribute :age, :integer
end

class Comment
  include Acfs::Model
  service CommentService

  attribute :text, :string
end
