# Ubiquitous Language

Every application and system incorporates some amount and type of *domain knowledge*, originally expressed in terminology familiar to domain experts as having specific meanings that are often meant to be an unambiguous shorthand for broader concepts. Too often, development teams implementing these software artefacts use different, less precise and/or specific terms, the variations between which introduce confusion between [Stakeholders](#stakeholder). Having an evolving but precisely-defined, uniformly-shared, yet evolving [ubiquitous language](http://blog.carbonfive.com/2016/10/04/ubiquitous-language-the-joy-of-naming/) eases development and improves communication by ensuring that "everybody means what they say they mean", preventing miscommunication and ambiguity from introducing defects and delays into what is already an imperfect, probably late, system.

The Ubiquitous Language (UL) for `Rack::ServiceApiVersioning` **must** define *all* terms used in specification, design, code comments, or other communication between [Stakeholders](#stakeholder) (possibly between a given Stakeholder and his or her future self) which lack, or differ from, a single, specific definition in standard technical written English. *This includes* terms that are primarily used in a technical context where the meaning of those terms is ordinarily open to multiple interpretations or meanings, as demonstrated by perusing the industry technical literature.

The Ubiquitous Language for `Rack::ServiceApiVersioning` **must** be compatible with, and is presumed to be a proper subset of, the UL for any application and/or [Platform](#platform) that uses it. Deviations from this are highly likely to cause miscommunication and misunderstanding due to ambiguity during the development of that larger application/Platform.

----

## Contents

- [The Rules](#the-rules)
  - [Capitalisation](#capitalisation)
    - [Exception for Requirement Level Keywords (RFC 2119)](#exception-for-requirement-level-keywords-rfc-2119)
  - [Additional Considerations for Requirement Level Keywords (RFC 2119)](#additional-considerations-for-requirement-level-keywords-rfc-2119)
  - [Common Words in Technical English](#common-words-in-technical-english)
  - [Non-Normative Supplemental Information](#non-normative-supplemental-information)
  - [Use of Temporary Placeholders](#use-of-temporary-placeholders)
  - [Term Context to be Reflected in Definition](#term-context-to-be-reflected-in-definition)
    - [Basic Policy](#basic-policy)
    - [Terms that Differ Between Contexts](#terms-that-differ-between-contexts)
    - [Highlighting Context with Multiple Definitions](#highlighting-context-with-multiple-definitions)
    - [Ordering of Multiple Contexts](#ordering-of-multiple-contexts)
    - [Meaning of Term Affected By Other Contexts](#meaning-of-term-affected-by-other-contexts)
  - [Term Closely Tied to Other Term(s)](#term-closely-tied-to-other-terms)
  - [Transitional Meaning of a Term](#transitional-meaning-of-a-term)
  - [Use of Term as Synonym (Cross-Reference)](#use-of-term-as-synonym-cross-reference)
  - [Link Formation](#link-formation)
  - [Link on First Use in a Paragraph](#link-on-first-use-in-a-paragraph)
  - [Optional Abbreviation After First Use in a Paragraph](#optional-abbreviation-after-first-use-in-a-paragraph)
  - [Use Non-Abbreviated Form on First Use in Subsequent Paragraph](#use-non-abbreviated-form-on-first-use-in-subsequent-paragraph)
- [The List](#the-list)
	- [Accept](#accept)
	- [API Version](#api-version)
	- [AVIDA](#avida)
	- [API Version-Independent Delivery Application](#api-version-independent-delivery-application)
	- [Component Service](#component-service)
	- [Content Negotiation](#content-negotiation)
	- [Deprecate](#deprecate)
	- [Endpoint](#endpoint)
	- [Entity](#entity)
	- [Glossary](#glossary)
	- [PDA](#pda)
	- [Platform](#platform)
	- [Primary Delivery Application](#primary-delivery-application)
	- [Register](#register)
	- [Request](#request)
	- [Repository](#request)
	- [Service](#service)
	- [Service Base URL](#service-base-url)
	- [Service Description](#service-description)
	- [Service Endpoint](#service-endpoint)
	- [Specification](#specification)
	- [Stakeholder](#stakeholder)
	- [Target Service](#target-service)
	- [Value Object](#value-object)
	- [Yank](#yank)

----

## The Rules

### Capitalisation

Ubiquitous Language terms **must** always have each word capitalised (e.g., Member Name). The definition **must** be in the singular for nouns, and third person simple present usage for verbs. Usage may be modified according to the rules of standard English as is normal for nouns (e.g., [Stakeholders](#stakeholder) is a collection of possibly multiple individuals, each of whom is a Stakeholder), verbs (e.g., [Requested](#request) as the simple past tense of Request), and so on. Such usage highlights that a Ubiquitous Language term is being discussed which has a meaning distinct from any it may have in standard English.

#### Exception for Requirement Level Keywords (RFC 2119)

Words defined in [RFC 2119](http://www.faqs.org/rfcs/rfc2119.html) as specifying interpretation of requirement levels, such as **must**, **may**, and **should**, **should not** be capitalised but instead rendered in **boldface**, following industry custom.

### Additional Considerations for Requirement Level Keywords (RFC 2119)

Words defined in [RFC 2119](http://www.faqs.org/rfcs/rfc2119.html) as specifying interpretation of requirement levels within a specification **should not** be linked to entries in this [Glossary](#glossary). Rather, the opening sections of the Specification or other document in question should incorporate the phrase recommended by the RFC, as follows (reformatted from the original):

> The key words **must**, **must not**, **REQUIRED**, **shall**, **shall not**, **should**, **should not**, **RECOMMENDED**, **may**, and **OPTIONAL** in this document are to be interpreted as described in [RFC 2119](http://www.faqs.org/rfcs/rfc2119.html).

### Common Words in Technical English

Words that occur and are used in the same sense as in the general technical literature, such as *device* or *text,* are not part of the Ubiquitous Language. If a specific context would be served by applying a more specific or variant definition of a term, it should be consistently distinguished from the generic term. Hence, *device* as opposed to a hypothetical *Frobulation Device*.

### Non-Normative Supplemental Information

Paragraphs in the definition of a term **may** be added that convey (primarily out-of-domain) additional supplemental information relevant to a term. These paragraphs **must** be added to the end of the discussion of a term, and **must** be preceded by a paragraph consisting solely of the text *Non-normative supplemental information follows.*

Such non-normative supplemental information **may** omit links to definitions of terms used that were linked to in the earlier,l normative section of the term definition.

### Use of Temporary Placeholders

As the Ubiquitous Language evolves and grows, and is recorded in this [Glossary](#glossary), a new definition may be added which references other terms not yet having Glossary entries. When circulating the draft Glossary to others for review and comment, those referenced entries **should** be created and linked to in the new entry. The Glossary maintainer **should** complete those definitions as well, but **may** instead choose to create an entry with the text "TBD." as the complete content. This is an indication to other reviewers that the term so listed is known to be relevant but has not yet been defined in the Glossary.

All [Glossary](#glossary) definitions relevant to a given artefact (and to those terms' definitions, and so on) **must** be defined in the Glossary before a Specification for that artefact is completed or meaningful code developed.

### Term Context to be Reflected in Definition

#### Basic Policy

Since the Ubiquitous Language includes terms that are defined in a domain context, a technical context, or both, each term **must** indicate at the beginning of its definition, the phrase *Domain term.* for domain terms or *Technical term.* for terms which are not relevant to a domain expert but have a specific meaning to technical [Stakeholders](#stakeholder).

#### Terms that Differ Between Contexts

Terms that have importantly different meanings between contexts should be defined sequentially under the same term, with the domain context first.

##### Highlighting Context with Multiple Definitions

When a term has definitions supplied for both contexts, *and* one of the contexts includes definitions for both a noun and a verb, then that context **must** be listed on a line by itself, as in the above example. If the domain context has definitions of both a noun and a verb, then both contexts **must** be listed on separate lines.

##### Ordering of Multiple Contexts

When domain-context and technical-context definitions are supplied for the same term, the domain-context definition **must** always be first.

##### Meaning of Term Affected By Other Contexts

When a term is *primarily* relevant in one context, but changes in the understanding of another may affect that meaning, then the context phrase definition **must** include the word *Primarily*.

If more than two contexts have been defined within this glossary, then the other affecting contexts **must** also be listed, e.g., "*Primarily technical term; affected by pseudo-financial context.*" This serves as a warning that changes in the listed secondary context(s) could in future affect the primary definition of the term.

### Term Closely Tied to Other Term(s)

When a [Glossary](#glossary) term is closely conceptually dependent on one or more others, then that linkage **must** be indicated by a phrase equivalent to "*With reference to (other term),*" at the start of the dependent term's definition. For an example of this, see [Restricted](#restricted).

### Transitional Meaning of a Term

The Ubiquitous Language *will* evolve as the application it defines evolves over its lifetime. However, some terms are considered more likely to change than others, often because their definition and use are tightly bound to business policies and rules more than to intrinsic domain terminology. The definition of these terms **must** include the *either* word **currently** *or* the word **initially**, modified for correct grammar.

For an example of how this is used, see the definition of [Restricted](#restricted).

### Use of Term as Synonym (Cross-Reference)

When a term has a commonly-used synonym that has identical meaning to the original in all relevant contexts, then the full definition **must** be listed under what is, or is expected to be, the most commonly-used form of the term. Synonymous entries are permitted, as with the example shown below for [Authorisation Role](#authorisation-role), a presently-punctilious more specific term for [Role](#role).

### Link Formation

A Ubiquitous Language term definition, when linked to within hypertext markup such as [Component Service](#component-service) or email **must** be formed using a normal link (e.g., HTML `<a></a>` tag pair) with the properly-capitalised Ubiquitous Language term as the link text and a URL which references the specific definition on this page. For example, a reference on this page to the term [Component Services](#component-service) would be rendered in Markdown as `[Component Services](#component-service)`. Note that, as mentioned previously, the term *in the URL* is in the singular, and words are separated within the URL by hyphen (`-`) characters rather than underscores.

### Link on First Use in a Paragraph

The first use of a Ubiquitous Language term in a paragraph within hypertext markup such as specifications or email **should** link to its definition in this [Glossary](#glossary) **unless** that definition has been linked to in a "recent" paragraph within the markup *and* the term may reasonably be presumed to be understood in specific detail by the reader. An example of such a term might be Member Name. Document authors **should** exercise judicious restraint in considering exceptions, and readers who feel that unwarranted exceptions have been made **should** so inform the author.

### Optional Abbreviation After First Use in a Paragraph

Ubiquitous Language terms **may** be abbreviated after their first use in a paragraph. where the first use calls attention to the fact that future abbreviations are being used informally.

### Use Non-Abbreviated Form on First Use in Subsequent Paragraph

The Ubiquitous Language term previously abbreviated is normally fully expanded for its first use in any subsequent paragraph.

------

## The List

### Accept

*Primarily technical term.* The [`Accept` header](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html) in the standard HTTP request headers is the basis of standard HTTP [content negotiation](#content-negotiiation). In our usage, [Clients](#client) making [Requests](#request) to a [Component Service](#component-service) **must** specify an `Accept` header with at least one content type specifying *either* that a specific [API Version](#api-version) of a specific Component Service is required (e.g., with a value of `vnd.example.apidemo.v4`) *or* that the latest available API Version of that Component Service is acceptable (with a comparable example of `vnd.example.apidemo`).

### API Version

*Technical term.* A sequential identifier, formed by the lower-case letter `v` and a positive ascending integer. Thus, `v1` would be the first version of a [Component Service](#component-service), `v2` would be a change (in API form or underlying implementation) from `v1`, and so on. Successive [API Versions](#api-version) increase in sequence, omitting only any API Versions which have been [Yanked](#yank).

In theory, any string can be used as an API Version identifier, though it traditionally revolves around numbers (e.g., '1', '2.7182.818.24'); a common convention is to prepend the lower-case letter `v` to such a number. All that is really required of an API Version identifier is that when two are compared lexically (as strings), the higher/later API Version has a higher/later sort order than the identifier it is being compared to.f


### API Version-Independent Delivery Application

*Technical term.* An executable application whose only purpose is to provide a non-API-Version-specific [Service Base URL](#service-base-url) for use by API clients, invoking the [Content Negotiation](#content-negotiation) middleware or equivalent which redirects (via HTTP 302, 307 or equivalent) to the [Primary Delivery Application](#primary-delivery-application) for a specific [API Version](#api-version).

### AVIDA

See [API Version-Independent Delivery Application](#api-version-independent-delivery-application).

### Client

An externally-developed and -maintained application or [Component Service](#component-service) which makes [Requests](#request) against the Component Service using this middleware in its [AVIDA](#avida).

### Component Service

*Technical term.* A Component Service is a self-contained, independently provisioned software construct that supplies part of the domain or supporting logic for a larger [Platform](#platform). Its only interface to or from other Component Services is via HTTP endpoints and JSON. Therefore, its definition, from the standpoint of any other component in the [System](#system), is expressed entirely in its interface, and no assumptions about implementation can or should be made. Evolution of a component, whether modifications to the API *or refactoring of the implementing code,* causes the [API Version](#api-version) to be incremented.

For a service to be a Component Service, it **must** meet each of the following criteria:

1. It **must** use HTTP as the sole means of initiating actions (via [Service Endpoints](#service-endpoint)) from outside code;
2. It **must** consist of an [API Version-Independent Delivery Application](#api-version-independent-delivery-application) and *one or more* [API Version](#api-version)-specific [Primary Delivery Application](#primary-delivery-application)s;
3. Its [AVIDA](#api-version-independent-delivery-application) **must** invoke [Content Negotiation](#content-negotiation) on each request for a [Service Endpoint](#service-endpoint);
4. It **must** [Register](#register) each API Version implemented with the service maintaining the [Repository](#repository) of currently-available Component Services, ordinarily using its [AVIDA](#api-version-independent-delivery-application)'s [Service Base URL](#service-base-url).

### Content Negotiation

*Technical term.* A standard feature of HTTP, normally used to select among multiple representations of the data being presented. This is commonly used for agreeing on the response's format (HTML, JSON, etc) and internationalisation (`en-gb`, `pt-br`, etc) to use.

Used by an application/[Platform](#platform) to select among (possibly) multiple supported [API Versions](#api-version) of a specific [Component Service](#component-service), with sensible default handling. For example, given a Platform named `acme` and an `ApiDemo` Component Service that supports API Versions `1` and `2`, a request which specifies a value for the `Accept` HTTP header of `application/vnd.acme.apidemo.v1` will be served by the implementation of API Version `1`; a value of `application/vnd.acme.apidemo`, `application/*`, or `*/*` will be handled by the most recent API Version `2`, exactly as if it had been requested by a value of `application/vnd.acme.apidemo.v2`.

### Deprecate

*Technical term.* To serve notice that a specific [API Version](api-version) of a specific [Component Service](#component-service) **should not** be used since it will be removed from the [Platform](#platform)'s ecosystem at some future time. Initiating operation of a Component Service with one or more Deprecated API Versions, and/or accessing a [Service Endpoint](#service-endpoint) using a Deprecated API Version, **must** generate diagnostic messages using the customary means for operational monitoring, e.g., logging.

### Endpoint

See [Service Endpoint](#service-endpoint).

### Entity

*Technical term.* An Entity, is an object that is not defined by its attributes, but each instance has a distinct identity and thread of continuity (flow of internal state over its lifecycle).  Contrast [Value Object](#value-object).

The term Entity is sometimes casually used for an immutable piece of data that is more properly classed as a Value Object. If it is exclusively used for directly-read attribute values or simple derivations there from ("full name" as a combination of "given name" and "family name" is the classic example), then it *is* a Value Object and **must** be classed as such. Conversely, an Entity should modify its state through actions performed by methods, and minimise "raw" access to data (see *[Tell, Don't Ask](https://pragprog.com/articles/tell-dont-ask)*). A collaborator *asks* a Value Object for something; it *tells* an Entity to do something with itself. (An object that does something with objects *other than* itself is performing a service and is not, strictly speaking, an entity.)

*Non-normative supplemental information follows.*

The non-normative supplemental information for [Value Object](#value-object) is relevant here. *Unless* an object delivers significant value by having a mutable state over time, *and* is constantly maintained as a single Entity instance throughout by collaborating code, a Value Object **should** be used instead.

### Glossary

*Primarily domain term.* The document defining the [Ubiquitous Language](http://blog.carbonfive.com/2016/10/04/ubiquitous-language-the-joy-of-naming/) in use for and by a particular application or [Platform](#platform).

### PDA

See [Primary Delivery Application](#primary-delivery-application).

### Platform

*Technical term.* Refers to an aggregate of multiple applications and/or [Component Services](#component-service) which, collectively, provide a conceptually unified service or product to users (as opposed to [Clients](#client)). For example, Facebook is a platform; it is not a single, monolithic application.

### Primary Delivery Application

*Technical term.* The executable program/process implementing a specific [API Version](#api-version) of a specific [Component Service](#component-service), which **should** be redirected to by the [API Version-Independent Delivery Application](#api-version-independent-delivery-application). It **must** provide the API implemented by its [Service Endpoints](#service-endpoint) via HTTP.

### Register

*Technical term.* The process of making another [Component Service](#component-service) known to and addressable based upon information retrieved from the [Repository](#repository) used by this Gem's middleware.

### Repository

*Technical term.* A Repository, in general, intermediates between application-level logic and what is presumed to be (and generally treated as) persistent storage of structured data. Our middleware, specifically `ServiceComponentDescriber`, queries a Repository for information about the [Component Service](#component-service) implemented by the application hosting the middleware. How and whether that data is actually persisted, or how and how often that data is updated to match then-current conditions, are details unknown to and, practically speaking, irrelevant to, the middleware and its hosting application.

### Request

*Technical term.* Making an HTTP request, and acting upon its response, is the sole means of interacting with a [Component Service](#component-service) as that concept is defined here. The Request **must** specify the Component Service addressed by the request, and **must** *either* specify a specific [API Version](#api-version) of that Service *or* specify that the latest (most recent, highest version identifier) API Version is acceptable.

### Service

*Technical term.* See [Component Service](#component-service).

### Service Base URL

*Technical term.* The common base of all [Service Endpoints](#service-endpoint) for a given [Component Service](#component-service). An [AVIDA](#avida) and a corresponding [API Version](#api-version)-specific [Primary Delivery Application](#primary-delivery-application) each have unique Service Base URLs.

The URL to access a specific [Service Endpoint](#service-endpoint) is formed by appending the path information and query parameters, if any, to the Service Base URL for the Component Service being addressed.

### Service Description

*Primarily technical term.* A string which describes the purpose and/or function of a [Service Component](#service-component) with greater semantic meaning than a [Service Name](#service-name). Like a Service Name, this **must** also be unique within the [System](#system). It is primarily for the benefit of UI mechanisms which describe Service Component information in an operationally relevant context.

### Service Endpoint

*Technical term.* Uniquely identified by combining a [Service Base URL](#service-base-url) and [Action Name](#action-name), this, after making use of the Content Negotiation [Utility Component](#utility-component), invokes a function or method in a specific API Version of the implementing code responsible for performing a useful action or accessing a useful resource as part of a [Component Service](#component-service).

### Service Name

*Technical term.* A short string used to uniquely identify a [Component Service](#component-service) internally within the Conversagence ecosystem. This is distinct from the [Service Description](#service-description). It **must** be unique within the [System](#system).

### Specification

*Primarily technical term.* In the Ubiquitous Language, specifically refers to the specification of the API and associated functionality of a specific [Component Service](#component-service), typically defined in a single hypertext document similar to this one.

Specifications are expected to converge on a common set of formatting and content standards that **must** be documented here after multiple source samples establish those standards through usage and review between Stakeholders.

### Stakeholder

*Domain term.* An individual or cohesive collection of individuals participating in the continuing development, including supporting business operations, of the Conversagence Project. These include, but are not limited to, [Members](#member), developers, operational specialists, domain experts, and investors. Each of these, and others, have a "stake" in the success of the Project and the organisation, and each are essential contributors to that success.

### Target Service

*Technical term.* Used by a Utility Component's code or Specification to refer to the Component Service on whose behalf it is performing work. This term's first use in a specific context **must** make clear whether this term refers to *any* API Version of the Component Service being targeted rather than to a *single* API Version as is the intended default usage of the term.

### Value Object

*Technical term.* Value Objects have no identity or flow of internal state (they are immutable), and are defined by their attribute values. Examples are colours (which are expressed using values such as sRGB and CMYK), geolocations (latitude and longitude values), and so on. Two value objects may be compared on the basis of their attributes (the location for Springfield is not the same as the location for Singapore), but assignment normally does not make sense in context (e.g., changing the values for the "location of Singapore" object to those of the "location of Springfield" object and expecting to continue to see the two as having distinct meaning). Contrast [Entity](#entity).

*Non-normative supplemental information follows.*

*In general,* immutable value objects are to be preferred in use to mutable entities; when an "updated" object is needed, instantiate a new object and delete (or garbage-collect) the old one. Maintaining and preserving mutable state is a fraught enterprise that sucks resources and is a traditionally rich source of defects.

### Yank

*Technical term.* To Yank a specific [API Version](#api-version) of a specific [Specification](#specification) is to remove it from possible use by any [Component Service](#component-service). This **should** normally be done after the API Version in question has been [Deprecated](#deprecate) for a period of time, generally due to later changes in the API obsoleting the to-be-Yanked API Version.

Yanking a specific [API Version](#api-version) **may** also be necessary as part of an urgent security response, when vulnerabilities or other critical failures have been discovered in the version in question.
