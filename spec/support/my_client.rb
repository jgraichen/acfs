
class MyClient < Acfs::Client

end

class MyModel
  include Acfs::Model

  attr_accessor :name, :age
  private :age=
end
