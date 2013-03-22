module Acfs

  module Formats

    def json?
      headers['Content-Type'] == 'application/json'
    end
  end
end
