module Acfs::Model

  # = Acfs Attributes
  #
  # Allows to specify attributes of a class with default values and type safety.
  #
  # @example
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

    # @api public
    #
    # Write default attributes defined in resource class.
    #
    # Optional attributes will not be initialized.
    #
    # @see #write_attributes
    # @see ClassMethods#attributes
    #
    def initialize(*attrs)
      self.write_attributes self.class.attributes
      reset_changes
      super
    end

    # @api public
    #
    # Returns ActiveModel compatible list of attributes and values.
    #
    # Will not include not set optional attributes.
    #
    # @example
    #   class User
    #     include Acfs::Model
    #     attribute :name, type: String, default: 'Anon'
    #   end
    #   user = User.new(name: 'John')
    #   user.attributes # => { "name" => "John" }
    #
    # @return [ HashWithIndifferentAccess{ Symbol => Object } ] Attributes and their values.
    #
    def attributes
      @attributes ||= HashWithIndifferentAccess.new
    end

    # @api public
    #
    # Update all attributes with given hash. Attribute values will be casted
    # to defined attribute type.
    #
    # @example
    #   user.attributes = { :name => 'Adam' }
    #   user.name # => 'Adam'
    #
    # @param [ Hash{ String, Symbol => Object }, #each{|key, value|} ] attributes to set in resource.
    # @see #write_attributes Delegates attributes hash to `#write_attributes`.
    #
    def attributes=(attributes)
      write_attributes attributes
    end

    # @api public
    #
    # Read an attribute from instance variable.
    #
    # @param [ Symbol, String ] name Attribute name.
    # @return [ Object ] Attribute value.
    #
    def read_attribute(name)
      self.attributes[name.to_s]
    end

    # @api public
    #
    # Write a hash of attributes and values.
    #
    # If attribute value is a `Proc` it will be evaluated in the context
    # of the resource after all non-proc attribute values are set. Values
    # will be casted to defined attribute type.
    #
    # The behavior is used to apply default attributes from resource
    # class definition.
    #
    # @example
    #   user.write_attributes { :name => 'john', :email => lambda{ "#{name}@example.org" } }
    #   user.name  # => 'john'
    #   user.email # => 'john@example.org'
    #
    # @param [ Hash{ String, Symbol => Object, Proc }, #each{|key, value|} ] attributes to write.
    # @see #write_attribute Delegates attribute values to `#write_attribute`.
    #
    def write_attributes(attributes, opts = {})
      unless attributes.respond_to?(:each) && attributes.respond_to?(:keys)
        return false
      end

      if opts.fetch(:unknown,:ignore) == :raise
        if (attributes.keys.map(&:to_s) - self.class.attributes.keys).any?
          raise ArgumentError.new "Unknown attributes: #{(attributes.keys - self.class.attributes.keys).map(&:inspect).join(', ')}"
        end
      end

      procs = {}

      attributes.each do |key, _|
        if attributes[key].is_a? Proc
          procs[key] = attributes[key]
        else
          write_local_attribute key, attributes[key], opts
        end
      end

      procs.each do |key, proc|
        write_local_attribute key, instance_exec(&proc), opts
      end

      true
    end

    # @api private
    #
    # Check if a public getter for attribute exists that should be called to
    # write it or of {#write_attribute} should be called directly. This is
    # necessary as {#write_attribute} should go though setters but can also
    # handle unknown attribute that will not have a generated setter method.
    #
    def write_local_attribute(name, value, opts = {})
      method = "#{name}="
      if respond_to? method, true
        public_send method, value
      else
        write_attribute name, value, opts
      end
    end

    # @api public
    #
    # Write single attribute with given value. Value will be casted
    # to defined attribute type.
    #
    # @param [ String, Symbol ] name Attribute name.
    # @param [ Object ] value Value to write.
    # @raise [ ArgumentError ] If no attribute with given name is defined.
    #
    def write_attribute(name, value, opts = {})
      attr_type = self.class.defined_attributes[name.to_s]
      if attr_type
        write_raw_attribute name, attr_type.cast(value), opts
      else
        write_raw_attribute name, value, opts
      end
    end

    # @api private
    #
    # Write an attribute without checking type or existence or casting
    # value to attributes type. Value be stored in an instance variable
    # named after attribute name.
    #
    # @param [ String, Symbol ] name Attribute name.
    # @param [ Object ] value Attribute value.
    #
    def write_raw_attribute(name, value, _ = {})
      self.attributes[name.to_s] = value
    end

    module ClassMethods

      # @api public
      #
      # Define a model attribute by name and type. Will create getter and
      # setter for given attribute name. Existing methods will be overridden.
      #
      # Available types can be found in `Acfs::Model::Attributes::*`.
      #
      # Optional attributes will not be included in most attribute listing
      # unless they are populated from server or client.
      #
      # @example
      #   class User
      #     include Acfs::Model
      #     attribute :name, :string, default: 'Anon'
      #     attribute :email, :string, default: lambda{ "#{name}@example.org"}
      #     attribute :profile, :string, optional: true
      #   end
      #
      # @param [ #to_sym ] name Attribute name.
      # @param [ Symbol, String, Class ] type Attribute type identifier or type class.
      #
      def attribute(name, type, opts = {})
        if type.is_a? Symbol or type.is_a? String
          type = "::Acfs::Model::Attributes::#{type.to_s.classify}".constantize
        end

        define_attribute name.to_sym, type, opts
      end

      # @api public
      #
      # Return list of possible attributes and default values for this model class.
      #
      # This method will not include attributes marked as optional.
      #
      # @example
      #   class User
      #     include Acfs::Model
      #     attribute :name, :string
      #     attribute :age, :integer, default: 25
      #   end
      #   User.attributes # => { "name": nil, "age": 25 }
      #
      # @return [ Hash{ String => Object, Proc } ] Attributes with default values.
      #
      def attributes
        Hash.new.tap do |attrs|
          defined_attributes.each do |key, attr|
            attrs[key] = attr.default_value unless attr.optional?
          end
        end
      end

      def defined_attributes
        @attributes ||= {}.merge superclass.respond_to?(:defined_attributes) ? superclass.defined_attributes : {}
      end

      # @api public
      #
      # Return hash of attributes and there types.
      #
      # @example
      #   class User
      #     include Acfs::Model
      #     attribute :name, :string
      #     attribute :age, :integer, default: 25
      #   end
      #   User.attributes # => { "name": Acfs::Model::Attributes::String, "age": Acfs::Model::Attributes::Integer }
      #
      # @return [ Hash{ Symbol => Class } ] Attributes and their types.
      #
      def attribute_types
        @attribute_types ||= {}.merge superclass.respond_to?(:attribute_types) ? superclass.attribute_types : {}
      end

      private
      def define_attribute(name, type, opts = {})
        name             = name.to_s
        attribute        = type.new opts

        defined_attributes[name] = attribute
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
Dir[File.dirname(__FILE__) + '/attributes/*.rb'].sort.each do |path|
  filename = File.basename(path)
  require "acfs/model/attributes/#{filename}"
end
