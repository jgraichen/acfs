# Changelog

## Unreleased

---

### New

### Changes

### Fixes

### Breaks

## 2.1.0 - (2025-02-14)

---

### New

- Experimental support for OpenTelemetry

## 2.0.0 - (2025-01-17)

---

### New

- Add support for Rails 7.2 and 8.0
- Add support for Ruby 3.3 and 3.4

### Changes

- Use newer Ruby syntax for performance and code improvements

### Breaks

- Require Ruby 3.1+ and Rails 7.0+

## 1.7.0 - (2022-01-24)

---

### New

- Support for Ruby 3.1 and Rails 7.0

## 1.6.0 - (2021-01-07)

---

### New

- Support Ruby 3.0
- Use keyword arguments in parameters and when calling methods

## 1.5.1 - (2020-12-30)

---

### Changes

- Revert to using `::MultiJson`

## 1.5.0 - (2020-06-19)

---

### New

- Error classes for more HTTP error responses: `400`, `401`, `403`, `500`, `502`, `503`, `504`.

### Changes

- Replace deprecated `MultiJson` with core JSON module

## 1.4.0 - (2020-06-12)

---

### New

- Use strict TCP keep alive probing by default (5s/5s)
- Adapter accepts curl request opts

## 1.3.4 - (2020-03-22)

---

### Fixes

- Empty package build for Gem release 1.3.3

## 1.3.3 - (2020-03-22)

---

### Changes

- Improved handling of low-level connection errors and timeouts

## 1.3.2 - (2019-09-24)

### Fixes

- Fix `Acfs.on` callbacks for empty `find_by` results (#42)

---

## 1.3.1 - (2019-07-02)

### Fixes

- Improve URL argument encoding when building resource requests

## 1.3.0

- Change default error messages to a more compact representation to ease integration with error reporting services.

## 1.2.1

- Fix issues with resources errors if response payload differs from the expected `field => [messages]`, such as `field => message` or `[messages]`.

## 1.2.0

- Add Rails 5.2 compatibility

## 1.1.1

- `each_item`: Pass collection to provided block (#40)

## 1.1.0

- Add support for Rails 5.1

## 1.0.1

- Fix deprecation warnings when using ::Mime

## 1.0.0

- Switch to first non-development major as its long time used in production.
- Fix NewRelic RPM inference with middleware stack inherited from `ActionDispatch::MiddlewareStack`.

## 0.48.0

- Remove #attribute_types broke since f7e4109 (Sep 2013, v0.23)
- Fix attribute inheritance on child classes broken since commit 7cf1d11 (Apr 2014, v0.43)

## 0.47.0

- Change blank value handling of dict and list type (0a12ef1)

## 0.46.0

- Rework types system (#39)

## 0.45.0

- Fetching multiple records (`find(ary)`) is stable now, but untested (#38)
- Middleware stack is build on `ActionDispatch::MiddlewareStack` now
- Deprecate legacy middleware names (`xyEncoder`, `xyDecoder`)

## 0.44.0

- Add option to configure adapter creation and pass option to `typhoeus` adapter e.g. limiting concurrency.

## 0.43.2

- add `total_count` for paginated collections

## 0.43.1

- Fix `:with` condition matching on stubs

## 0.43.0

- Remove `Acfs::Model` (inherit from `Acfs::Resource`)
- Stub does only a partial match of `:with` attributes now
- Allow blocks as stub `:return`s

## 0.42.0

- Add simple dict attribute type

## 0.40.0

- Change `Resource#persisted?` to return true if it is not new

## 0.39.1

- Fix automatic path parameter handling for #destroy

## 0.39.0

- Add new event `acfs.operation.before_process`

## 0.38.0

- Allow middlewares to abort request processing
- Allow middlewares to receive the request operation object (via the request)

## 0.37.0

- Add `Acfs.on`

## 0.36.0

- Add #each_page and #each_item query methods

## 0.35.0

- Add instrumentation support

## 0.34.1

- Fix leaking failed requests in request queues

## 0.34.0

- Add support for will_paginate view helper used with `Acfs::Collection`s
- Add support for pagination header added by [paginate-responder](https://github.com/jgraichen/paginate-responder)
- Improve `Resource#new?` detection by using `loaded?` instead of presence of `:id` attribute

## 0.33.0

- Do not raise errors on unknown attributes by default, add :unknown option.
- Add support to store unknown attributes

## 0.32.1

- Fix multiple callbacks on `QueryMethods#all`

## 0.32.0

- Add new attribute type `UUID`

## 0.31.0

- Add experimental support for multiple and chained paths with placeholders

## 0.30.0

- Add experimental support for multiple operation callbacks (Acfs.add_callback)

## 0.29.1

- Fix: rescue `NameError` and `NoMethodError` on invalid type

## 0.29.0

- Add find_by!

## 0.28.0

- Add find_by

## 0.27.0

- Reset method to clear stubs, request queues, internal state
- Add RSpec helper to enable stubs and clear state after each spec

## 0.26.0

- Add support for singleton resources

## 0.25.0

- Add option to allow blank attribute values (Johannes Jasper)
- Internal changes

## 0.24.0

- Fix issues with stubs using type inheritance
- Allow '1' as true value for boolean attributes (Tino Junge)

## 0.23.2

- Fix regression in delegator usage by #find due to resource type inheritance.

## 0.23.1

- Fix error class name typo

## 0.23.0

- Add Resource Type Inheritance

## 0.22.2

- Preserve errors received from service on revalidation (2f1fc178)
- Fix parameter ordering bug on stubs (1dc78dc8)

## 0.22.1

- Fix hash modification on iteration bug on `ActiveModel::Errors` due to string keys in error hash

## 0.22.0

- Fill local resource errors hash also on 422 responses when saving resources

## 0.21.1

- Fix wrong validation context

## 0.21.0

- Add update_attributes
- Add validation check to `save` method
- Inherit attributes to subclasses

## 0.20.0

- Remove messaging
- Introduce `Acfs::Resource`

## 0.19.0

- Add support for `DateTime` and `Float` attribute types
- Add experimental list attribute type
- Allow block usage in stub `with` option
- Allow testing if operation stubs were called and how often
- Fix bug on operation stubs

## 0.18.0

- Basic DELETE operations

## 0.17.0

- Basic messaging
- Extensible YARD documentation

## 0.16.0

- Add YAML configuration
- Add external configuration for services
- Add Rubinius support

## 0.15.0

- Add stubbing capabilities for resources

## 0.14.0 & 0.13.0

- Fix response attributes

## 0.12.0

- Add JRuby support
- Improve handling of error responses (422)

## 0.11.0

- Add Logger Middleware
- Add handling of error responses

## 0.10.0

- Return hash with indifferent access for resource attributes

## 0.9.0

- Add create operation

## 0.8.0

- Add save operation (PUT and POST)
- Add JSON and MessagePack encoder middlewares for encoding request data
- `ActiveModel::Dirty`
- Add persistent state methods

## 0.7.0

- Per-service middleware stack

## 0.6.0

- Add support for multiple IDs for `.find`
- Add MessagePack support

## 0.5.1

- Fix mime type parsing for mime types with additional parameters (`ActionPack` < 4.0)

## 0.5.0

- Add mime type support for responses

## 0.4.0

- Improve JSON response detection
- Add boolean attribute type

## 0.3.0

- Add tracking for loading state (if resource is loaded or queued)
- Add JSON middleware to decode responses
- Add middleware support
- Add method to fetch single resources or list of resources
- Use typhoeus as HTTP library for parallel request processing

## 0.2.0

- Allow defining resources and attributes

## 0.1.0

- Project start
