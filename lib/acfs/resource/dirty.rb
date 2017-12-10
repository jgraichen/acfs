class Acfs::Resource
  #
  # Thin wrapper around ActiveModel::Dirty
  #
  module Dirty
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods

    NULL = Object.new # :nodoc:
    private_constant :NULL

    included do
      attribute_method_suffix '_changed?', '_change', '_will_change!', '_was'
      attribute_method_suffix '_previously_changed?', '_previous_change'
      attribute_method_affix prefix: 'restore_', suffix: '!'
    end

    # Returns `true` if any of the attributes have unsaved
    # changes, `false` otherwise.
    #
    # @example
    #   person.changed? # => false
    #   person.name = 'bob'
    #   person.changed? # => true
    #
    # @return Boolean
    #
    def changed?
      changed_attributes.present?
    end

    # Returns an array with the name of the attributes with
    # unsaved changes.
    #
    # @example
    #   person.changed # => []
    #   person.name = 'bob'
    #   person.changed # => ["name"]
    #
    # @return [Array<String>]
    #
    def changed
      changed_attributes.keys
    end

    # Returns a hash of changed attributes indicating their original
    # and new values like `attr => [original value, new value]`.
    #
    # @example
    #   person.changes # => {}
    #   person.name = 'bob'
    #   person.changes # => { "name" => ["bill", "bob"] }
    #
    # @return [HashWithIndifferentAccess{String => Object}]
    #
    def changes
      ::ActiveSupport::HashWithIndifferentAccess[changed.map {|attr| [attr, attribute_change(attr)] }]
    end

    # Returns a hash of attributes that were changed before the
    # model was saved.
    #
    # @example
    #   person.name # => "bob"
    #   person.name = 'robert'
    #   person.save
    #   person.previous_changes # => {"name" => ["bob", "robert"]}
    #
    # @return [HashWithIndifferentAccess{String => Array<Object>}]
    #
    def previous_changes
      @previously_changed ||= ::ActiveSupport::HashWithIndifferentAccess.new
    end

    # Returns a hash of the attributes with unsaved changes indicating
    # their original values like `attr => original value`.
    #
    # @example
    #   person.name # => "bob"
    #   person.name = 'robert'
    #   person.changed_attributes # => {"name" => "bob"}
    #
    # @return [HashWithIndifferentAccess{String => Object}]
    #
    def changed_attributes
      @changed_attributes ||= ::ActiveSupport::HashWithIndifferentAccess.new
    end

    # @api private
    #
    # Invoked by method_missing
    #
    def attribute_changed?(attr, from: NULL, to: NULL)
      !!changes_include?(attr) &&
        (to == NULL || to == _read_attribute(attr)) &&
        (from == NULL || from == changed_attributes[attr])
    end

    # @api private
    #
    # Invoked by method_missing
    #
    def attribute_was(attr)
      attribute_changed?(attr) ? changed_attributes[attr] : _read_attribute(attr)
    end

    # @api private
    #
    # Invoked by method_missing
    #
    def attribute_previously_changed?(attr) #:nodoc:
      previous_changes_include?(attr)
    end

    # Restore all previous data of the provided attributes.
    def restore_attributes(attributes = changed)
      attributes.each { |attr| restore_attribute! attr }
    end

    # @api private
    #
    def save!(*)
      super.tap {|_| changes_applied }
    end

    # @api private
    #
    def loaded!
      clear_changes_information
      super
    end

    # @api private
    #
    def write_raw_attribute(name, value, opts = {})
      attribute_will_change! name if opts[:change].nil? || opts[:change]
      super
    end

    private

    def changes_include?(attr_name)
      changed_attributes.include?(attr_name)
    end

    def previous_changes_include?(attr_name)
      previous_changes.include?(attr_name)
    end

    def changes_applied
      @previously_changed = changes
      @changed_attributes = ::ActiveSupport::HashWithIndifferentAccess.new
    end

    def clear_changes_information
      @previously_changed = ::ActiveSupport::HashWithIndifferentAccess.new
      @changed_attributes = ::ActiveSupport::HashWithIndifferentAccess.new
    end

    # Invoked by method_missing
    #
    def attribute_change(attr)
      [changed_attributes[attr], _read_attribute(attr)] if attribute_changed?(attr)
    end

    def attribute_will_change!(attr)
      return if attribute_changed?(attr)

      begin
        value = _read_attribute(attr)
        value = value.duplicable? ? value.clone : value
      rescue TypeError, NoMethodError
      end

      changed_attributes[attr] = value
    end

    # Invoked by method_missing
    #
    def restore_attribute!(attr)
      if attribute_changed?(attr)
        __send__("#{attr}=", changed_attributes[attr])
        clear_attribute_changes([attr])
      end
    end

    # Remove changes information for the provided attributes.
    def clear_attribute_changes(attributes)
      changed_attributes.except!(*attributes)
    end

    def _read_attribute(attr)
      send(attr)
    end
  end
end
