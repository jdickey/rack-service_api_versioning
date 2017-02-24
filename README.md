# Rack::ServiceApiVersioning

This Gem implements three Rack middleware components that, together, enable possibly multiple API Versions of one or more Component Services to be active at the same time. Incoming requests for a service specify their version requirements, if any, with an `Accept` HTTP header.

----

## Contents

1. [A Note on Terminology](#a-note-on-terminology)
   1. [Ubiquitous Language](#ubiquitous-language)
   2. [Requirement-Level Keywords](#requirement-level-keywords)
2. [Installation](#installation)
3. [Usage](#usage)
	1. [An Overview of the Protocol](#an-overview-of-the-protocol)
	2. [The API Version-Independent Delivery Application](#the-api-version-independent-delivery-application)
	3. [The Repository](#the-repository)
	4. [The API Version Implementation's Primary Delivery Application](#the-api-version-implementations-primary-delivery-application)
4. [Development](#development)
   1. [Prerequisites](#prerequisites)
   1. [Running Tests](#running-tests)
   2. [Feasible Future Features](#feasible-future-features)
   	1. [Public-Key Encryption](#public-key-encryption)
   	2. [Other Ideas?](#other-ideas)
5. [Contributing](#contributing)
   1. [Process](#process)
   2. [Notes on Contributing](#notes-on-contributing)
6. [License](#license)

## A Note on Terminology

### Ubiquitous Language

This Gem was developed to support a larger project involving a collection of separately packaged, independent Component Services communicating via HTTP, with any data transfer objects encoded as JSON. As such, these middleware components use a subset of that project's [Ubiquitous Langauge](https://martinfowler.com/bliki/UbiquitousLanguage.html), which is documented in the file [`UBIQUITOUS_LANGUAGE.md`](https://github.com/jdickey/rack-service_api_versioning/blob/master/UBIQUITOUS_LANGUAGE.md) in the `/doc` directory.

These terms, when used in this or other documents, can be identified as probable Ubiquitous Language terms by their use of initial capital letters, as demonstrated *by* the usage of *Ubiquitous Language* itself.

### Requirement-Level Keywords

Additionally, the keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://tools.ietf.org/html/rfc2119). These keywords **must** be styled in a **strong** ("bold") font face when used in this or other related documents; rendering them in grammatically-appropriate case rather than in ALL CAPS is a **recommended** variance from the RFC *unless* the author is certain that the audience will be viewing the content only as raw text, in which case the ALL CAPS styling is strongly **recommended.**

## Installation

The middleware components in this Gem are intended for use in an API Version-independent Delivery Application, or AVIDA. They will not normally be used by API Version implementations or by other applications not developed using this protocol for API Version disambiguation. Therefore, this Gem will ordinarily be added to the Gemfile of such an AVIDA, rather than installed in the system Gem repository.

Add this line to the Gemfile for an API Version-independent Delivery Application:

```ruby
gem 'rack-service_api_versioning'
```

And then execute:

    $ bundle

## Usage

### An Overview of the Protocol

An application platform may be constructed of a number of separately-maintained components, including [use case or use story](https://martinfowler.com/bliki/UseCasesAndStories.html) implementations running as separate Primary Delivery Applications, or *PDAs.* Each of these is invoked by and interacts with other Component Services via HTTP, with data objects encoded using JSON. Each of these also is ordinarily versioned independently of others, which presents challenges when a Component Service and its PDA (collectively, a *Target Service*) are updated:

* How do its collaborators, which may be implemented and maintained by different teams, ensure that they collaborate only with a known-good version of the Target Service when the possibility exists that new versions may introduce breaking changes?
* How do new API Versions of the Target Service evolve and implement functionality, or even simple API changes, that introduce breaking changes without being hobbled by fealty to backwards compatibility?
* Given the above, how can multiple API Versions of a given Target Service be deployed *in the same system* to meet the needs of different clients which have not all updated to the latest version due to API changes?
* From an operational perspective, how can the system maintain adequate resilience if a newly-deployed API Version's PDA of a Service proves unreliable, yet all clients will happily work with previous API Versions if the new one is unavailable?
* How can network- and server-related issues such as failover or migration be dealt with while maintaining continuous availability of the larger system?

One solution is to define a single Service Base URL for each Component Service, with the AVIDA application accessible via that URL existing solely to generate HTTP redirects to the Service Base URL for the Primary Delivery Application of a given API Version. The AVIDA **must not** implement code to serve Service Endpoints itself, as they will never be accessed when using the middleware correctly. The middleware components get information about the currently-available API Versions by querying a [Repository](#the-repository); maintaining the correctness and currency of that data is outside the scope of this document (or this Gem).

Below, we discuss the three artefacts directly involved with the use of the Rack middleware components in this Gem: the AVIDA (API Version-Independent Primary Delivery Application); the Repository containing information about currently available API Versions; and the API Implementation Primary Delivery Application (PDA).

### The API Version-Independent Delivery Application

The API Version-Independent Delivery Application, or AVIDA, is a stub which has two purposes:

* to provide a single, canonical Service Base URL for a given Component Service regardless of API Version (hence the name), and
* to host the Rack middleware components implemented in this Gem, which redirect requests to the appropriate API Version-specific Primary Delivery Application (PDA) based on HTTP content negotiation.

The AVIDA **must not** implement routing or other logic of its own. It **must** provide a Repository instance, as [specified](#the-repository), containing information about the available API Versions to the `ServiceComponentDescriber` middleware component.

Because these are Rack middleware components, the AVIDA **must** be a Ruby app. The middleware should work correctly with any Ruby framework or library that supports Rack, including [Sinatra](http://www.sinatrarb.com), [Roda](http://roda.jeremyevans.net), or even [Rails](http://rubyonrails.org). Similarly, the data persistence underlying the Repository implementation is irrelevant here, so long as the class fulfilling that role implements the specified API properly.

### The Repository

The Repository is an object which returns an array of zero or more entities describing Component Services and their API Versions asserted to be presently available for use by external clients via HTTP.

The Repository is queried via its `#find` method. The method takes as its parameter a Hash of entity attribute/value pairs, the only one of which that is guaranteed to be significant here being `:name`, which is matched against the short `:name` of available entities (see the next paragraph). The `#find` method returns an array of entities, which will be empty if no matches were found.

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

### The API Version Implementation's Primary Delivery Application

The API Version Implementation's PDA is an application running on a server accessible to the AVIDA. Requests received by the AVIDA which are resolved to a specific API Version's PDA are redirected to it with the presumption that it will respond appropriately to such HTTP requests, including path information, query parameters, body content, and so on as supplied with the HTTP request received by the AVIDA.

No further assumptions about the operation of the PDA are made by the AVIDA or these Rack middleware components. Their implementation, resource usage, and other similar concerns are explicitly out of the scope of this document, the AVIDA, or the Rack middleware components comprising this Gem.

## Development

After checking out the repo, run `bin/setup` to install dependencies (which as of now must already be in­stalled on your local system). Then, run `bin/rake test` to run the tests, or `bin/rake` to run tests and, if tests are successful, further static-analysis tools ([RuboCop](https://github.com/bbatsov/rubocop), [Flay](https://github.com/seattlerb/flay), [Flog](https://github.com/seattlerb/flog), and [RubyCritic](https://github.com/whitesmith/rubycritic)).

To install *your build* of this Gem onto your local machine, run `bin/rake install`. We recom­mend that you uninstall any previously-installed "official" Gem to increase your confi­dence that your tests are running against *your* build. You should then be able to either run tests or test the middleware components from within your set of applications (AVIDA and PDA).

### Prerequisites

The development setup as automated by `bin/setup` assumes that

1. you're using [`rbenv`](https://github.com/rbenv/rbenv) for Ruby version management;
2. you have the [`rbenv-gemset`](https://github.com/jf/rbenv-gemset) plugin installed (see [here](https://gist.github.com/MicahElliott/2407918) for a quick setup HOWTO).

Gemsets make life easier, both by maintaining a pristine system Gem repository and by guaranteeing that a program can be rebuilt with the *exact same versions* of Gems as was used to build a specific commit. Our use of Gemsets, as shown in the [`gemsets/setup_and_bundle.sh`](https://github.com/jdickey/rack-service_api_versioning/tree/master/gemsets/setup_and_bundle.sh) file and the [gemspec](https://github.com/jdickey/rack-service_api_versioning/tree/master/rack-service_api_versioning.gemspec), can be seen as "imposing a burden" on maintainence by requiring that Gem version updates be made consistently in both files, but it more than compensates for that by ensuring that each Gem directly used by *our* Gem doesn't have any "stealth updates" applied against it that risk changing functionality.

### Running Tests

Running tests works just as you would expect for individual MiniTest::Spec test scripts; you can run a command line such as `ruby test/rack/service_api_versioning/service_component_describer_test.rb` to run a single test-spec file. Also, running `rake` and `rake test` works just as you'd expect for running the complete set of tests.

### Feasible Future Features

#### Public-Key Encryption

The initial release of this Gem itself uses no encryption; if HTTPS rather than HTTP is used between Component Services, that would provide an increased level of security. HTTPS, however, is not presently **required,** but is **recommended.** An imminent future release is being considered which would use the [RbNaCl](https://github.com/cryptosphere/rbnacl) library's support for [public-key encryption](https://github.com/cryptosphere/rbnacl/wiki/SimpleBox#public-key-encryption-with-simplebox) to secure and authenticate HTTP payloads and, where practical, message data.

#### Other Ideas?

Do you see something we missed that you'd find useful? Open an [issue and PR](#process) and let's have a chat about it!

## Contributing

1. [Fork it](https://github.com/jdickey/rack-service_api_versioning
/fork);
1. *Please* open an issue on this repo so we can discuss your feature. Features which reflect a consensus reached are much more likely to be merged quickly;
1. Create your feature branch (`git checkout -b NNN-my-new-feature`) where `NNN` is the issue number for the aforementioned discussion;
1. Ensure that your changes are completely covered by *passing* specs, and comply with the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) as enforced by [RuboCop](https://github.com/bbatsov/rubocop). To verify this, run `bundle exec rake`, noting and repairing any lapses in coverage or style violations;
1. Commit your changes (`git add .; git commit`). Please *do not* use a single-line commit message (`git commit -am "some message"`). A good commit message notes what was changed and why in sufficient detail that a relative newcomer to the code can understand your reasoning and your code. We **recommend** (but do not yet enforce) commit messages conforming to [these conventions](http://karma-runner.github.io/1.0/dev/git-commit-msg.html);
1. Push to the branch (`git push origin NNN-my-new-feature`). Remember that the first time pushing a branch to a remote requires an "unconditional" push (`git push -u origin NNN-my-new-feature`);
1. Create a new Pull Request. In the initial message, reference the open issue where your feature has been discussed; if no such issue exists (why?), then describe at some length the rationale for your new feature; your implementation strategy at a higher level than each individual commit message; anything future maintainers should be aware of; and so on. Modifications to existing code *must* have been discussed in an issue for PRs containing them to be accepted and merged;
1. Don't be discouraged if the PR generates further discussion leading to further refinement of your PR through additional commits. These should *generally* be discussed in comments on the relevant issue; discussion in the Gitter room (see below) may also be useful;
1. If you've comments, questions, or just want to talk through your ideas, come hang out in the project's [room on Gitter](https://gitter.im/jdickey/wisper_subscription). Ask away!

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

Copyright &copy; 2017, Jeff Dickey and Prolog Systems (Singapore) Private Limited.
