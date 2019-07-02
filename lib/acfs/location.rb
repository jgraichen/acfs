module Acfs
  # @api private
  #
  # Describes a URL with placeholders.
  #
  class Location
    attr_reader :arguments, :raw, :struct, :args

    REGEXP = /^:([A-z][A-z0-9_]*)$/

    def initialize(uri, args = {})
      @raw       = URI.parse uri
      @args      = args
      @struct    = raw.path.split('/').reject(&:empty?).map {|s| s =~ REGEXP ? Regexp.last_match[1].to_sym : s }
      @arguments = struct.select {|s| s.is_a?(Symbol) }
    end

    def build(args = {})
      unless args.is_a?(Hash)
        raise ArgumentError.new "URI path arguments must be a hash, `#{args.inspect}' given."
      end

      self.class.new raw.to_s, args.merge(self.args)
    end

    def extract_from(*args)
      args = {}.tap do |collect|
        arguments.each {|key| collect[key] = extract_arg key, args }
      end

      build args
    end

    def str
      uri = raw.dup
      uri.path = '/' + struct.map {|s| lookup_arg(s, args) }.join('/')
      uri.to_s
    end

    def raw_uri
      raw.to_s
    end
    alias_method :to_s, :raw_uri

    private

    def extract_arg(key, hashes)
      hashes.each_with_index do |hash, index|
        return (index == 0 ? hash.delete(key) : hash.fetch(key)) if hash.key?(key)
      end

      nil
    end

    def lookup_arg(arg, args)
      arg.is_a?(Symbol) ? lookup_replacement(arg, args) : arg
    end

    def lookup_replacement(sym, args)
      value = get_replacement(sym, args).to_s
      return ::URI.encode_www_form_component(value) unless value.empty?

      raise ArgumentError.new "Cannot replace path argument `#{sym}' with empty string."
    end

    def get_replacement(sym, args)
      args.fetch(sym.to_s) do
        args.fetch(sym) do
          if args[:raise].nil? || args[:raise]
            raise ArgumentError.new "URI path argument `#{sym}' missing on `#{self}'. Given: `#{args}.inspect'"
          else
            ":#{sym}"
          end
        end
      end
    end
  end
end
