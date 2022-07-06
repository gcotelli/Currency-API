"
A CurrencyRESTfulControllerTest is a test class for testing the behavior of CurrencyRESTfulController
"
Class {
	#name : #CurrencyRESTfulControllerTest,
	#superclass : #SingleResourceRESTfulControllerTest,
	#instVars : [
		'userStory'
	],
	#category : #'Currency-API-Model-Tests'
}

{ #category : #asserting }
CurrencyRESTfulControllerTest >> assertMediaType: aStringOrMediaType equals: anotherStringOrMediaType [

	self assert: aStringOrMediaType asMediaType equals: anotherStringOrMediaType asMediaType
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> baseUrl [

	^ 'http://api.example.com' asUrl
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> currencyVersion1MediaType [

	^ resourceController currencyVersion1dot0dot0MediaType copy version: '1'
]

{ #category : #running }
CurrencyRESTfulControllerTest >> setUp [

	self setUpUserStoryTest.
	super setUp
]

{ #category : #running }
CurrencyRESTfulControllerTest >> setUpResourceController [

	resourceController := CurrencyRESTfulController workingWith: userStory rootSystem
]

{ #category : #running }
CurrencyRESTfulControllerTest >> setUpUserStoryTest [

	userStory := PluggableUserStoryTest requiring: [ :test | 
		             test registerSubsystem: CurrencyManagementSystem new ].
	userStory setUp
]

{ #category : #tests }
CurrencyRESTfulControllerTest >> testCurrenciesWhenEmpty [

	| response |

	response := resourceController
		            currenciesBasedOn:
		            ( self requestToGET: self resourceUrl accepting: self currencyVersion1MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assertMediaType: response contentType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		withJsonFromItemsIn: response do: [ :items | self assert: items isEmpty ]
]
