# frozen_string_literal: true

require 'json'

def response(data = nil, opts = {})
  if data
    opts[:body] = JSON.dump(data)
    opts[:headers] ||= {}
    opts[:headers]['Content-Type'] = 'application/json'
  end
  opts
end
