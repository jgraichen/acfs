
class MyClient < Acfs::Client
  resources :users, class: 'MyUser'
end

class MyUser
  include Acfs::Model

  attribute :name, default: 'Anon'
  attribute :age, :integer
end
