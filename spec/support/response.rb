require 'json'

def response(data = nil, opts = {})
  if data
    opts.merge! body: JSON.dump(data)
    opts[:headers] ||= {}
    opts[:headers].merge! 'Content-Type' => 'application/json'
  end
  opts
end
