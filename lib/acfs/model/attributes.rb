module Acfs::Model

  # == Acfs Attributes
  #
  # Allows to specify attributes of a class with default values and type safety.
  #
  #   class User
  #     include Acfs::Model
  #     attribute :name, :string, default: 'Anon'
  #     attribute :age, :integer
  #     attribute :special, My::Special::Type
  #   end
  #
  # For each attribute a setter and getter will be created and values will be
  # type casted when set.
  #
  module Attributes
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    def initialize(*attrs) # :nodoc:
      self.write_attributes self.class.attributes, change: false
      super *attrs
    end

    # Returns ActiveModel compatible list of attributes and values.
    #
    #   class User
    #     include Acfs::Model
    #     attribute :name, type: String, default: 'Anon'
    #   end
    #   user = User.new(name: 'John')
    #   user.attributes # => { "name" => "John" }
    #
    def attributes
      self.class.attributes.keys.inject({}) { |h, k| h[k.to_s] = public_send k; h }
    end

    # Update all attributes with given hash.
    #
    def attributes=(attributes)
      write_attributes attributes
    end

    # Read an attribute.
    #
    def read_attribute(name)
      instance_variable_get :"@#{name}"
    end

    # Write a hash of attributes and values.
    #
    def write_attributes(attributes, opts = {})
      procs = {}

      attributes.each do |key, _|
        if attributes[key].is_a? Proc
          procs[key] = attributes[key]
        else
          write_attribute key, attributes[key], opts
        end
      end

      procs.each do |key, proc|
        write_attribute key, instance_exec(&proc), opts
      end
    end

    # Write an attribute.
    #
    def write_attribute(name, value, opts = {})
      if (type = self.class.attribute_types[name.to_sym]).nil?
        raise "Unknown attribute #{name}."
      end

      write_raw_attribute name, type.cast(value), opts
    end

    # Write an attribute without checking type and existence or casting
    # value to attributes type.
    #
    def write_raw_attribute(name, value, _ = {})
      instance_variable_set :"@#{name}", value
    end

    module ClassMethods # :nodoc:

      # Define a model attribute by name and type. Will create getter and
      # setter for given attribute name. Existing methods will be overridden.
      #
      #   class User
      #     include Acfs::Model
      #     attribute :name, :string, default: 'Anon'
      #   end
      #
      # Available types can be found in `Acfs::Model::Attributes::*`.
      #
      def attribute(name, type, opts = {})
        if type.is_a? Symbol or type.is_a? String
          type = "::Acfs::Model::Attributes::#{type.to_s.classify}".constantize
        end

        define_attribute name.to_sym, type, opts
      end

      # Return list of possible attributes and default values for this model class.
      #
      #   class User
      #     include Acfs::Model
      #     attribute :name, :string
      #     attribute :age, :integer, default: 25
      #   end
      #   User.attributes # => { "name": nil, "age": 25 }
      #
      def attributes
        @attributes ||= {}
      end

      # Return hash of attributes and there types.
      #
      def attribute_types
        @attribute_types ||= {}
      end

      private
      def define_attribute(name, type, opts = {}) # :nodoc:
        default_value    = opts.has_key?(:default) ? opts[:default] : nil
        default_value    = type.cast default_value unless default_value.is_a? Proc
        attributes[name] = default_value
        attribute_types[name.to_sym] = type
        define_attribute_method name

        self.send :define_method, name do
          read_attribute name
        end

        self.send :define_method, :"#{name}=" do |value|
          write_attribute name, value
        end
      end
    end
  end
end

# Load attribute type classes.
#
Dir[File.dirname(__FILE__) + "/attributes/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "acfs/model/attributes/#{filename}"
end
