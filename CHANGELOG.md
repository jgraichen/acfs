# Changelog

## Next

* Do not raise errors on unknown attributes by default, add :unknown option.

## 0.32.1

* Fix multiple callbacks on `QueryMethods#all`

## 0.32.0

* Add new attribute type `UUID`

## 0.31.0

* Add experimental support for multiple and chained paths with placeholders

## 0.30.0

* Add experimental support for multiple operation callbacks (Acfs.add_callback)

## 0.29.1

* Fix: rescue NameError and NoMethodError on invalid type

## 0.29.0

* Add find_by!

## 0.28.0

* Add find_by

## 0.27.0

* Reset method to clear stubs, request queues, internal state
* Add RSpec helper to enable stubs and clear state after each spec

## 0.26.0

* Add support for singleton resources

## 0.25.0

* Add option to allow blank attribute values (Johannes Jasper)
* Internal changes

## 0.24.0

* Fix issues with stubs using type inheritance
* Allow '1' as true value for bool attributes (Tino Junge)

## 0.23.2

* Fix regression in delegator usage by #find due to resource type inheritance.

## 0.23.1

* Fix error class name typo

## 0.23.0

* Add Resource Type Inheritance

## 0.22.2

* Preserve errors received from service on revalidation (2f1fc178)
* Fix parameter ordering bug on stubs (1dc78dc8)

## 0.22.1

* Fix hash modification on iteration bug on ActiveModel::Errors due to string keys in error hash

## 0.22.0

* Fill local resource errors hash also on 422 responses when saving resources

## 0.21.1

* Fix wrong validation context

## 0.21.0

* Add update_attributes
* Add validation check to `save` method
* Inherit attributes to subclasses

## 0.20.0

* Remove messaging
* Introduce `Acfs::Resource`

## 0.19.0

* Add support for DateTime and Float attribute types
* Add experimental list attribute type
* Allow block usage in stub `with` option
* Allow to test if operation stubs were called and how often
* Fix bug on operation stubs

## 0.18.0

* Basic DELETE operations

## 0.17.0

* Basic messaging
* Extensible YARD documentation

## 0.16.0

* Add YAML configuration
* Add external configuration for services
* Add Rubinius support

## 0.15.0

* Add stubbing capabilities for resources

## 0.14.0 & 0.13.0

* Fix response attributes

## 0.12.0

* Add JRuby support
* Improve handling of error respones (422)

## 0.11.0

* Add Logger Middleware
* Add handling of error responses

## 0.10.0

* Return hash with indifferent access for resource attributes

## 0.9.0

* Add create operation

## 0.8.0

* Add save operation (PUT and POST)
* Add JSON and MessagePack encoder middlewares for encoding request data
* ActiveModel::Dirty
* Add persistant state methods

## 0.7.0

* Per-service middleware stack

## 0.6.0

* Add support for multiple ids for .find
* Add MessagePack support

## 0.5.1

* Fix mime type parsing for mime types with aditional parameters (ActionPack < 4.0)

## 0.5.0

* Add mime type support for respones

## 0.4.0

* Improve JSON response detection
* Add bool attribute type

## 0.3.0

* Add tracking for loading state (if resource is loaded or queued)
* Add JSON middleware to decode respones
* Add middleware support
* Add method to fetch single resources or list of resources
* Use typhoeus as http library for parallel request processing

## 0.2.0

* Allow to define resources and attributes

## 0.1.0

* Project start
