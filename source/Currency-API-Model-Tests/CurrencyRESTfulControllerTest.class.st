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

{ #category : #'private - asserting' }
CurrencyRESTfulControllerTest >> assertETag: anEntityTag valueEquals: anETagValue [

	self assert: anEntityTag value equals: anETagValue
]

{ #category : #asserting }
CurrencyRESTfulControllerTest >> assertMediaType: aStringOrMediaType equals: anotherStringOrMediaType [

	self assert: aStringOrMediaType asMediaType equals: anotherStringOrMediaType asMediaType
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> baseUrl [

	^ 'http://api.example.com' asUrl
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> createJapaneseYen [

	| response |

	response := resourceController
		            createCurrencyBasedOn: ( self
				              requestToPOST: '{
											"singularName":"Japanese Yen",
											"ISO4217Code":"JPY",
											"issueDate":"1871-06-27"}'
				              as: resourceController currencyVersion1dot0dot0MediaType
				              accepting: self currencyVersion1MediaType )
		            within: self newHttpRequestContext.

	self assert: response isCreated.

	^ response
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> currencyVersion1MediaType [

	^ resourceController currencyVersion1dot0dot0MediaType copy version: '1'
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> mediumOfExchangeVersion1MediaType [

	^ resourceController mediumOfExchangeVersion1dot0dot0MediaType copy version: '1'
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> requestToPOST: body as: contentType accepting: mediaType [

	^ ( self requestToPOST: body as: contentType )
		  setAccept: mediaType;
		  yourself
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

	| fixedUUIDGenerator |

	fixedUUIDGenerator := ( ( 0 to: 5 ) collect: [ :index | 
		                        UUID fromString:
			                        ( '00000000-0000-0000-0000-00000000000<1p>' expandMacrosWith: index ) ] )
		                      readStream.
	userStory := PluggableUserStoryTest requiring: [ :test | 
		             test registerSubsystem: ( CurrencyManagementSystem using: fixedUUIDGenerator ) ].
	userStory setUp
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantCreateCurrencyMissingISOCodeAndShortName [

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"singularName":"United States Dollar",
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"issueDate":"1792-04-02"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError badRequest
		withMessageText: 'Missing #shortName field.'
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantCreateCurrencyMissingIssueDate [

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"singularName":"Japanese Yen",
											"ISO4217Code":"JPY"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError badRequest
		withMessageText: 'Missing #issueDate field.'
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantCreateCurrencyMissingSingularName [

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"ISO4217Code":"USD",
											"issueDate":"1792-04-02"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError badRequest
		withMessageText: 'Missing #singularName field.'
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantCreateCurrencyWithEmptyPluralName [

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"singularName":"United States Dollar",
											"pluralName":"",
											"subUnitDenominator":100,
											"ISO4217Code":"USD",
											"issueDate":"1792-04-02"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
		withMessageText: 'A currency can''t have an empty name'
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantCreateCurrencyWithEmptySingularName [

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"singularName":"",
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"ISO4217Code":"USD",
											"issueDate":"1792-04-02"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
		withMessageText: 'A currency can''t have an empty name'
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantCreateCurrencyWithFractionalSubUnitDenominator [

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"singularName":"United States Dollar",
											"pluralName":"United States Dollars",
											"subUnitDenominator":0.1,
											"ISO4217Code":"USD",
											"issueDate":"1792-04-02"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
		withMessageText: 'The sub-unit denominator must be a strictly positive integer'
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantCreateCurrencyWithInvalidDate [

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"singularName":"United States Dollar",
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"ISO4217Code":"USD",
											"issueDate":"XXX"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
		withMessageText: ' Expect a two digit year, got XXX'
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantCreateCurrencyWithInvalidISOCode [

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"shortName":"USD",
											"singularName":"United States Dollar",
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"ISO4217Code":"US",
											"issueDate":"1792-04-02"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
		withMessageText: 'ISO 4217 code must have exactly three letters'
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantCreateCurrencyWithInvalidShortName [

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"shortName":"US",
											"singularName":"United States Dollar",
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"issueDate":"1792-04-02"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
		withMessageText: 'A currency short name must have between 3 and 6 letters'
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCreateAbkhazianApsar [

	| response |

	response := resourceController
		            createCurrencyBasedOn: ( self
				              requestToPOST: '{
											"shortName":"APSAR",
											"singularName":"Apsar",
											"pluralName":"Apsark",
											"issueDate":"2008-09-26"}'
				              as: resourceController currencyVersion1dot0dot0MediaType
				              accepting: self currencyVersion1MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isCreated;
		assertMediaType: response contentType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: '2f7439dd82ca7d2aaff48edd8ed9ff2c346f50fa';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'APSAR';
				assert: json singularName equals: 'Apsar';
				assert: json pluralName equals: 'Apsark';
				assert: json subUnitDenominator equals: 1;
				assert: json ISO4217Code isNil;
				assert: json issueDate equals: '2008-09-26';
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			].

	self assert: ( userStory rootSystem >> #CurrencyManagementSystem ) currencies notEmpty
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCreateSeveralCurrencies [

	self testCreateUSD.
	self createJapaneseYen.

	self assert: ( userStory rootSystem >> #CurrencyManagementSystem ) currencies size equals: 2
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCreateUSD [

	| response |

	response := resourceController
		            createCurrencyBasedOn: ( self
				              requestToPOST: '{
											"singularName":"United States Dollar",
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"ISO4217Code":"USD",
											"issueDate":"1792-04-02"}'
				              as: resourceController currencyVersion1dot0dot0MediaType
				              accepting: self currencyVersion1MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isCreated;
		assertUrl: response location equals: self resourceUrl / '00000000-0000-0000-0000-000000000000';
		assertMediaType: response contentType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: 'ae7eb486885d4e56bad695c0973d4e287fc08049';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'USD';
				assert: json singularName equals: 'United States Dollar';
				assert: json pluralName equals: 'United States Dollars';
				assert: json subUnitDenominator equals: 100;
				assert: json ISO4217Code equals: 'USD';
				assert: json issueDate equals: '1792-04-02';
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			].

	self assert: ( userStory rootSystem >> #CurrencyManagementSystem ) currencies notEmpty
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCreateUSDAcceptingMediumOfExchange [

	| response |

	response := resourceController
		            createCurrencyBasedOn: ( self
				              requestToPOST: '{
											"singularName":"United States Dollar",
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"ISO4217Code":"USD",
											"issueDate":"1792-04-02"}'
				              as: resourceController currencyVersion1dot0dot0MediaType
				              accepting: self mediumOfExchangeVersion1MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isCreated;
		assertMediaType: response contentType
		equals: resourceController mediumOfExchangeVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: '16cdba4bdac5e9ade7e2f871c51a16ded1752cbb';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'USD';
				assert: json singularName equals: 'United States Dollar';
				assert: json pluralName equals: 'United States Dollars';
				assert: json subUnitDenominator equals: 100;
				assert: json issueDate isNil;
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			].

	self assert: ( userStory rootSystem >> #CurrencyManagementSystem ) currencies notEmpty
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCreateUSDAcceptingUnifOfAccount [

	| response |

	response := resourceController
		            createCurrencyBasedOn: ( self
				              requestToPOST: '{
											"singularName":"United States Dollar",
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"ISO4217Code":"USD",
											"issueDate":"1792-04-02"}'
				              as: resourceController currencyVersion1dot0dot0MediaType
				              accepting: self unitOfAccountVersion1MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isCreated;
		assertMediaType: response contentType
		equals: resourceController unitOfAccountVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: '50ee7153ccd0a0ab29ec63063ba181ba7f483c7f';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'USD';
				assert: json singularName equals: 'United States Dollar';
				assert: json pluralName equals: 'United States Dollars';
				assert: json subUnitDenominator isNil;
				assert: json issueDate isNil;
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			].

	self assert: ( userStory rootSystem >> #CurrencyManagementSystem ) currencies notEmpty
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCreateYen [

	| response |

	response := self createJapaneseYen.

	self
		assertMediaType: response contentType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: 'b2d5362b2470a42dff4488028a35d36df95a9357';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'JPY';
				assert: json singularName equals: 'Japanese Yen';
				assert: json pluralName equals: 'Japanese Yen';
				assert: json subUnitDenominator equals: 1;
				assert: json ISO4217Code equals: 'JPY';
				assert: json issueDate equals: '1871-06-27';
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			].

	self assert: ( userStory rootSystem >> #CurrencyManagementSystem ) currencies notEmpty
]

{ #category : #tests }
CurrencyRESTfulControllerTest >> testCurrencies [

	| response |

	self testCreateSeveralCurrencies.

	response := resourceController
		            currenciesBasedOn:
		            ( self requestToGET: self resourceUrl accepting: self unitOfAccountVersion1MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assertMediaType: response contentType
		equals: resourceController unitOfAccountVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		withJsonFromContentsIn: response
		do: [ :json | self assertUrl: json selfLocation equals: 'http://api.example.com/currencies' ];
		withJsonFromItemsIn: response do: [ :items | 
			| yen usd |

			self assert: items size equals: 2.
			yen := items first.
			self
				assert: yen shortName equals: 'JPY';
				assertUrl: yen selfLocation
				equals: 'http://api.example.com/currencies/00000000-0000-0000-0000-000000000001'.
			usd := items second.
			self
				assert: usd shortName equals: 'USD';
				assertUrl: usd selfLocation
				equals: 'http://api.example.com/currencies/00000000-0000-0000-0000-000000000000'
			]
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

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> unitOfAccountVersion1MediaType [

	^ resourceController unitOfAccountVersion1dot0dot0MediaType copy version: '1'
]
