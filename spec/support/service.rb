
class UserService < Acfs::Client
  resources :users, class: 'MyUser'
end

class CommentService < Acfs::Client
  resources :comments
end

class MyUser
  include Acfs::Model

  attribute :name, :string, default: 'Anon'
  attribute :age, :integer
end

class Comment
  include Acfs::Model

  attribute :text, :string
end
