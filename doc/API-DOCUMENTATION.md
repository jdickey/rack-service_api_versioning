<h1>Contents</h1>

# Contents

- [Before We Get Started](#before-we-get-started)
  * [A Note on Terminology](#a-note-on-terminology)
  * [FAQ for This Document](#faq-for-this-document)
- [Setup in the AVIDA](#setup-in-the-avida)
- [The `ServiceComponentDescriber` Middleware Component](#the-servicecomponentdescriber-middleware-component)
  * [The Repository](#the-repository)
    + [Repository Value Schemata](#repository-value-schemata)
  * [Error Reporting](#error-reporting)
- [The `AcceptContentTypeSelector` Middleware Component](#the-acceptcontenttypeselector-middleware-component)
  * [Inputs from Rack Environment](#inputs-from-rack-environment)
  * [Error Reporting](#error-reporting-1)
- [The `ApiVersionRedirector` Middleware Component](#the-apiversionredirector-middleware-component)
  * [Error Reporting](#error-reporting-2)
- [Feasible Future Features](#feasible-future-features)
  * [Other Ideas?](#other-ideas)

# Before We Get Started

## A Note on Terminology

The section [*A Note on Terminology*](https://github.com/jdickey/rack-service_api_versioning/README.md#a-note-on-terminology), including description of this project's [Ubiquitous Langauge](https://github.com/jdickey/rack-service_api_versioning/doc/UBIQUITOUS-LANGUAGE.md) and [Requirement-Level Keywords](https://github.com/jdickey/rack-service_api_versioning/README.md#requirement-level-keywords), is incorporated herein by reference.

## FAQ for This Document

<dl>
<dt>Why the Funky Header for "Contents"?</dt>
<dd>We use the [`markdown-toc`](https://github.com/nok/markdown-toc) Node (and Atom) package to generate the table of contents. That package understands Markdown syntax for headers; it does not fully comprehend that Markdown is a proper superset of HTML, and so HTML headers are valid, too. Since we don't want the "Contents" header itself to appear in the TOC, using the HTML markup gives the desired result. 
</dd>
</dl>

# Setup in the AVIDA

A typical AVIDA might read something like the following:

```ruby

require 'awesome_print'

require_relative './repository'

# Code for Acme Apidemo Service Component, API Version `v1`, namespaced in this module.
module AcmeApiDemoV1
  # Roda/Rack app to serve as API Demo Component Service delivery mechanism.
  # Remember that Roda's convention is to set `response.status` to 200 by
  # default, which is just fine for most cases.
  # Reek complains about a :reek:UncommunicativeVariableName. Ah, convention.
  class ServiceApp < Roda
    use Rack::Session::Cookie, secret: ENV['ACME_APIDEMO_SESSION_COOKIE_SECRET']
    plugin :default_headers, 'Content-Type' => 'application/json'
    use ServiceComponentDescriber, repository: DummyRepository.new,
                                   service_name: 'apidemo'
    use AcceptContentTypeSelector
    use ApiVersionRedirector

    route do |r|
      r.post 'register' do
        'Hello from #register. I MUST NOT be shown. params: ' + r.params.ai
      end
    end # route
  end # class ServiceCatalogueUcV1::ServiceApp
end
```

Note that, although the demo code above uses (the underappreciated, awesome) [Roda](http://roda.jeremyevans.net) framework, the middleware works with any framework built on [Rack](http://rack.github.io); this includes Rails, Sinatra, [Brooklyn](https://github.com/luislavena/brooklyn), or [anything else](http://codecondo.com/12-small-ruby-frameworks/) that runs on top of Rack.

What's important is the use of the three middleware components `ServiceComponentDescriber`, `AcceptContentTypeSelector`, and `ApiVersionRedirector`; their ordering in the main application module *prior to* any routing or other application logic; and the parameters (for `ServiceComponentDescriber`). Each will be discussed in turn below.

# The `ServiceComponentDescriber` Middleware Component

The `ServiceComponentDescriber` middleware component is the first of our three middleware components to be used in an AVIDA for a Component Service. It **must** be invoked with parameters for `repository` and `service_name`. These parameters **may** be in either order.

The component retrieves information concerning the implementation(s) of a specific named Component Service from a Repository whose data has been provided by an external service, formats that data into a JSON string which it uses to set a value in the Rack environment (using the key `'COMPONENT_DESCRIPTION'`), and then passes that environment on to the next link in the Rack call chain (which in practice **should** be the next middleware component).

## The Repository

The Repository is an object which returns an array of zero or more entities describing Component Services and their API Versions asserted to be presently available for use by external clients via HTTP.

The Repository is queried via its `#find` method. The method takes as its parameter a Hash of entity attribute/value pairs, the only one of which that is guaranteed to be significant here being `:name`, which is matched against the short `:name` of available entities (see the next paragraph). The `#find` method returns an array of entities, which will be empty if no matches were found.

### Repository Value Schemata

Each entity returned from `#find` **must** have the following attributes:

| Attribute | Type | Description | Example |
| --------- | ---- | ----------- | ------- |
| `name` | string | Short, unique name of a single Component Service | `apidemo` |
| `description` | string | Non-empty descriptive text for the Component Service | `The API Demo Component Service` |
| `api_versions` | array of object | Array of one or more API Version descriptor entities (see table below) |

The Repository **must** return one or more API Version descriptor entities in the `api_versions` attribute above. In the event that a Component Service with the requested name nominally exists but has no API Versions preferably available, the Repository's `#find` method **must** return an **empty* array result.

Each API Version descriptor entities **must** have attributes as follows:

| Attribute | Type | Description | Example |
| --------- | ---- | ----------- | ------- |
| `base_url` | string | Service Base URL for this specific API Version of this specific Component Service. | `http://example.com:9876/api/` |
| `content_type` | string | MIME content type sent in `Accept` header to explicitly specify this specific API Version of this specific Component Service. | `application/vnd.examplecorp.apidemo.v1+json` |
| `restricted` | Boolean | Reserved for future use. Must be `false`. | `false` |
| `deprecated` | Boolean | Reserved for future use. Must be `false`. | `false` |

## Error Reporting

If the attempt to retrieve information from the Repository using the value passed in the `service_name` parameter is unsuccessful, then the `ServiceComponentDescriber` will abort the Rack request processing, returning an HTTP status code [404](https://httpstatuses.com/404) (*Not Found*), with a response body that simply contains the text, *Service not found: "bad-service-name"*.

# The `AcceptContentTypeSelector` Middleware Component

The `AcceptContentTypeSelector` middleware component

1. parses the JSON encoded into the `COMPONENT_DESCRIPTION` value by the `ServiceComponentDescriber` middleware component;
2. parses and interprets the requested API Version as specified by the Content Type specified in the `Accept` HTTP header (available in the Rack environment at `HTTP_ACCEPT`);
	1. if a suitable API Version is identified, encodes that API Version's details into a new `COMPONENT_API_VERSION_DATA` entry in the Rack environment;
	2. if no suitable API Version is identified, returns a Rack response with status code [406](https://httpstatuses.com/406) (*Not Acceptable*), and a message body enumerating the Content Type values which would have resulted in a successful request for the Component Service in question;
3. unless aborted with an error, proceeds on to the next component in the Rack middleware chain.

## Inputs from Rack Environment

The `AcceptContentTypeSelector` middleware component requires two entries to be set in the Rack environment (the `env` passed into its `#call` method).

The `COMPONENT_DESCRIPTION` value contains a JSON-serialised object describing a Component Service and the API Versions presently operational and available for that Service. This is ordinarily set by the [`ServiceComponentDescriber`](#the-servicecomponentdescriber-middleware-component) component described above.

The `HTTP_ACCEPT` value represents the standard `Accept` header used for HTTP content negotiation. It will normally have one or more segments of the format

> `application/vnd.COMPANYORORG.APINAME.vSTR+json`

where

* `vnd` is a conventional abbreviation for "vendor"; i.e., for an application content type that is not part of the HTTP or related IETF Standards;
* `COMPANYORORG` is the name of the company or organisation responsible for maintaining the application on whose behalf the Content Type is used. In our documentation for this gem, we have been using the example `acme`, for [Acme Corporation](https://en.wikipedia.org/wiki/Acme_Corporation);
* `APINAME` is the name of the application programming interface (or *API*) which these middleware components are being used to support. In the documentation for this Gem, we have been using the example `apidemo`, for the *API Demo Component Service*; and
* `STR` is an API-unique version identifier. Conventionally, and as demonstrated in this documentation, this has been an integer (which would presumably increment for each successive API Version release), giving an example such as `v1` or `v472`. In practice, it can be virtually *any* string-representable application-unique identifier; for those using [Semantic Versioning](http://semver.org), you might have an example such as `v1.0.0` or `v42.6.4-pre71`. As long as the version identifier is meaningful to you and your development team, it should be useable here.


## Error Reporting

The middleware component will abort processing of the request and return an HTTP error under any of the following conditions:

* An HTTP [400](https://httpstatuses.com/400) (*Bad Request*) will be returned if there is no defined `COMPONENT_DESCRIPTION` value or if that value does not contain valid [Repository](#the-repository) data in JSON format with at least one API Version defined; or
* An HTTP [406](https://httpstatuses.com/406) (*Not Acceptable*) will be returned if the API Version specifier in the `HTTP_ACCEPT` environment value does not match any API Versions reported as supported by parsing the `COMPONENT_DESCRIPTION` environment value.

# The `ApiVersionRedirector` Middleware Component

The `ApiVersionRedirector` middleware component parses the JSON encoded in the `COMPONENT_API_VERSION_DATA` value by the `AcceptContentTypeSelector` middleware component. It then builds a Rack response with

* the status code [307](https://httpstatuses.com/307) (*Temporary Redirect*);
* body content containing the markup `Please resend the request to <a href="LOCATION">LOCATION</a> without caching it.`, where `LOCATION` is replaced by the value of the `Location` header (see the next item); and
* headers for
  * `API-Version`, with a value of the API Version used to match the request (e.g., `v1` or `v2.14.6`); and
  * `Location`, with a value of the full URL for the API Version-specific request as supplied to the AVIDA, including path information and query parameters, if any.

## Error Reporting

**None.** If the `COMPONENT_DESCRIPTION` entry in the Rack environment is missing, or is invalidly formatted, then this middleware component *will* fail. Adding error detection and reporting similar to that of [`AcceptContentTypeSelector`](#the-servicecomponentdescriber-middleware-component), above, *but* the question may reasonably be asked, *how useful would that be in practice?* If these three components are always used together in the correct sequence, then there should be no possible error path for this middleware component; if an error is encountered in operation, that is a strong indication that the *use* of the middleware in that particular AVIDA is incorrect.

# Feasible Future Features

1. The initial release of this Gem itself uses no encryption; if HTTPS rather than HTTP is used between Component Services, that would provide an increased level of security. HTTPS, however, is not presently **required,** but is **recommended.** An imminent future release is being considered which would use the [RbNaCl](https://github.com/cryptosphere/rbnacl) library's support for [public-key encryption](https://github.com/cryptosphere/rbnacl/wiki/SimpleBox#public-key-encryption-with-simplebox) to secure and authenticate HTTP payloads and, where practical, message data.
2. Despite the explanation given for the deliberate omission of error reporting in the `ApiVersionRedirector` middleware component (immediately above), some intrepid soul may choose to implement it anyway. (It's open source; it's a platform for learning experiences.)
3. Some misadventurous developer may choose to implement the three existing middleware components *as a single, unified component.* We considered that approach during initial development, and abandoned it because we strongly feel that the "boilerplate" of including two "extra" middleware components is *far* outweighed by the inner complexity that such a unified component would contain, and the likelihood that any future change would have effects beyond the intended change. ([SOLID](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design)) *is* a thing, you know.)

## Other Ideas?

Do you see something we missed that you'd find useful? Open an [issue and PR](https://github.com/jdickey/rack-service_api_versioning/#contributing) and let's have a chat about it!
