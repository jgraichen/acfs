# frozen_string_literal: true

module Acfs
  # @api private
  #
  # Describes a URL with placeholders.
  #
  class Location
    attr_reader :arguments, :raw, :struct, :vars

    REGEXP = /^:([A-z][A-z0-9_]*)$/.freeze

    def initialize(uri, vars = {})
      @raw       = URI.parse uri
      @vars      = vars
      @struct    = raw.path.split('/').reject(&:empty?).map {|s| s =~ REGEXP ? Regexp.last_match[1].to_sym : s }
      @arguments = struct.select {|s| s.is_a?(Symbol) }
    end

    def build(vars)
      self.class.new raw.to_s, vars.stringify_keys.merge(self.vars)
    end

    def extract_from(*args)
      vars = {}
      arguments.each {|key| vars[key.to_s] = extract_arg(key, args) }

      build(vars)
    end

    def str
      uri = raw.dup
      uri.path = "/#{struct.map {|s| lookup_variable(s) }.join('/')}"
      uri.to_s
    end

    def raw_uri
      raw.to_s
    end
    alias to_s raw_uri

    private

    def extract_arg(key, hashes)
      hashes.each_with_index do |hash, index|
        if hash.key?(key)
          return (index.zero? ? hash.delete(key) : hash.fetch(key))
        end
      end

      nil
    end

    def lookup_variable(name)
      return name unless name.is_a?(Symbol)

      value = vars.fetch(name.to_s) do
        if @raise.nil? || @raise
          raise ArgumentError.new <<~ERROR.strip
            URI path argument `#{name}' missing on `#{self}'. Given: `#{vars}.inspect'
          ERROR
        end

        ":#{name}"
      end

      value = value.to_s.strip

      if value.empty?
        raise ArgumentError.new "Cannot replace path argument `#{name}' with empty string."
      end

      ::URI.encode_www_form_component(value)
    end
  end
end
