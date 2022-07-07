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

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> asUUID: string [

	^ UUID fromString: string
]

{ #category : #'private - asserting' }
CurrencyRESTfulControllerTest >> assertETag: anEntityTag valueEquals: anETagValue [

	self assert: anEntityTag value equals: anETagValue
]

{ #category : #'private - asserting' }
CurrencyRESTfulControllerTest >> assertMatchesJapaneseYenData: json [

	^ self
		  assert: json shortName equals: 'JPY';
		  assert: json singularName equals: 'Japanese Yen';
		  assert: json pluralName equals: 'Japanese Yen';
		  assert: json subUnitDenominator equals: 1;
		  assert: json ISO4217Code equals: 'JPY';
		  assert: json issueDate equals: '1871-06-27';
		  assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
]

{ #category : #'private - asserting' }
CurrencyRESTfulControllerTest >> assertMediaType: aStringOrMediaType equals: anotherStringOrMediaType [

	self assert: aStringOrMediaType asMediaType equals: anotherStringOrMediaType asMediaType
]

{ #category : #'private - asserting' }
CurrencyRESTfulControllerTest >> assertThereIsAtLeastOneCirculatingCurrency [

	self assert: self systemUnderTest currencies notEmpty
]

{ #category : #'private - asserting' }
CurrencyRESTfulControllerTest >> assertThereIsNoCirculatingCurrencies [

	| response |

	self assert: self systemUnderTest currencies isEmpty.

	response := resourceController
		            currenciesBasedOn:
		            ( self requestToGET: self resourceUrl accepting: self currencyVersion1MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		withJsonFromItemsIn: response do: [ :items | self assert: items isEmpty ]
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
CurrencyRESTfulControllerTest >> firstUUID [

	^ self asUUID: '00000000-0000-0000-0000-000000000000'
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> mediumOfExchangeVersion1MediaType [

	^ resourceController mediumOfExchangeVersion1dot0dot0MediaType copy version: '1'
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> requestToPATCHResourceIdentifiedBy: anIdentifier with: aRequestBody accepting: anAcceptHeader [

	^ TeaRequest
		  fromZnRequest: ( ( ZnRequest patch: ( self urlForResourceIdentifiedBy: anIdentifier ) )
				    setAccept: anAcceptHeader;
				    entity: ( ZnEntity with: aRequestBody type: anAcceptHeader );
				    yourself )
		  pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> requestToPOST: body as: contentType accepting: mediaType [

	^ ( self requestToPOST: body as: contentType )
		  setAccept: mediaType;
		  yourself
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> requestToPUTAt: url identifiedBy: anIdentifier [

	^ TeaRequest
		  fromZnRequest: ( ZnRequest put: url )
		  pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> retireFromCirculationCurrencyIn: createYenResponse [

	| getYenResponse |

	self withJsonFromContentsIn: createYenResponse do: [ :json | 
		resourceController
			retireFromCirculationBasedOn:
			( self requestToPUTAt: json links retireFromCirculation identifiedBy: self firstUUID )
			within: self newHttpRequestContext
		].
	getYenResponse := resourceController
		                  currencyBasedOn:
		                  ( self
			                    requestToGETResourceIdentifiedBy: self firstUUID
			                    accepting: self currencyVersion1MediaType )
		                  within: self newHttpRequestContext.
	self withJsonFromContentsIn: getYenResponse do: [ :json | 
		self
			assertMatchesJapaneseYenData: json;
			assert: json links retireFromCirculation isNil
		].
	self assert: self systemUnderTest allCurrencies notEmpty.
	self assertThereIsNoCirculatingCurrencies
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> secondUUID [

	^ self asUUID: '00000000-0000-0000-0000-000000000001'
]

{ #category : #running }
CurrencyRESTfulControllerTest >> sequentialIdentifiers [

	^ ( ( 0 to: 5 ) collect: [ :index | 
		    UUID fromString: ( '00000000-0000-0000-0000-00000000000<1p>' expandMacrosWith: index ) ] )
		  
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
		             test registerSubsystem:
			             ( CurrencyManagementSystem using: self sequentialIdentifiers readStream ) ].
	userStory setUp
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> systemUnderTest [

	^ userStory rootSystem >> #CurrencyManagementSystem
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
CurrencyRESTfulControllerTest >> testCantStoreCurrencyWithTheSameShortName [

	| response |

	response := self createJapaneseYen.

	self
		should: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"shortName":"JPY",
											"singularName":"Japanese Yen",
											"ISO4217Code":"JPY",
											"issueDate":"1871-06-27"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError conflict
		withMessageText: 'Something is in conflict with JPY - Japanese Yen'.

	self assert: self systemUnderTest currencies size equals: 1
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCantStoreTheSameCurrencyTwice [

	| response |

	response := self createJapaneseYen.

	self
		should: [ self createJapaneseYen ]
		raise: HTTPClientError conflict
		withMessageText: 'Something is in conflict with JPY - Japanese Yen'.

	self assert: self systemUnderTest currencies size equals: 1
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testCantUpdateCurrencyWhenETagDoesntMatch [

	| createRequest |

	createRequest := self createJapaneseYen.

	self
		should: [ 
			resourceController
				updateCurrencyBasedOn: ( self
						  requestToPATCHResourceIdentifiedBy: self firstUUID
						  with: '{"shortName":"YEN"}'
						  accepting: resourceController currencyVersion1dot0dot0MediaType
						  conditionalTo: '"XXX"' asEntityTag )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError preconditionFailed
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testCantUpdateCurrencyWhenETagIsMissing [

	| createRequest |

	createRequest := self createJapaneseYen.

	self
		should: [ 
			resourceController
				updateCurrencyBasedOn: ( self
						  requestToPATCHResourceIdentifiedBy: self firstUUID
						  with: '{"shortName":"YEN"}'
						  accepting: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError preconditionRequired
		withMessageText: 'Missing If-Match header.'
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testCantUpdateShortNameInConflictingWays [

	| createRequest |

	self testCreateUSD.
	createRequest := self createJapaneseYen.

	self
		should: [ 
			resourceController
				updateCurrencyBasedOn: ( self
						  requestToPATCHResourceIdentifiedBy: self secondUUID
						  with: '{"shortName":"USD"}'
						  accepting: resourceController currencyVersion1dot0dot0MediaType
						  conditionalTo: createRequest entityTag )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError conflict
		withMessageText: 'Something is in conflict with USD - Japanese Yen'
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testCantUpdateWithInvalidDate [

	| createRequest |

	createRequest := self createJapaneseYen.

	self
		should: [ 
			resourceController
				updateCurrencyBasedOn: ( self
						  requestToPATCHResourceIdentifiedBy: self firstUUID
						  with: '{"issueDate":"2020-XX-74"}'
						  accepting: resourceController currencyVersion1dot0dot0MediaType
						  conditionalTo: createRequest entityTag )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
		withMessageText: ' Expect a two digit month, got XX'
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testCantUpdateWithSeveralProblems [

	| createRequest |

	createRequest := self createJapaneseYen.

	self
		should: [ 
			resourceController
				updateCurrencyBasedOn: ( self
						  requestToPATCHResourceIdentifiedBy: self firstUUID
						  with: '{"ISO4217Code":"","subUnitDenominator":0}'
						  accepting: resourceController currencyVersion1dot0dot0MediaType
						  conditionalTo: createRequest entityTag )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
		withMessageText: 'The sub-unit denominator must be a strictly positive integer. ISO 4217 code must have exactly three letters'
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testCantUpdateYenNames [

	| createRequest |

	createRequest := self createJapaneseYen.

	self
		should: [ 
			resourceController
				updateCurrencyBasedOn: ( self
						  requestToPATCHResourceIdentifiedBy: self firstUUID
						  with: '{"singularName":"","pluralName":""}'
						  accepting: resourceController currencyVersion1dot0dot0MediaType
						  conditionalTo: createRequest entityTag )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
		withMessageText: 'A currency can''t have an empty name. A currency can''t have an empty name'
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testCantUpdateYenShortName [

	| createRequest |

	createRequest := self createJapaneseYen.

	self
		should: [ 
			resourceController
				updateCurrencyBasedOn: ( self
						  requestToPATCHResourceIdentifiedBy: self firstUUID
						  with: '{"shortName":""}'
						  accepting: resourceController currencyVersion1dot0dot0MediaType
						  conditionalTo: createRequest entityTag )
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
		assertETag: response entityTag valueEquals: 'd4700c5df1abfab896408256a8bf12dd20d0c927';
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
	self assertThereIsAtLeastOneCirculatingCurrency
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCreateCurrenciesWithTheSameName [

	self testCreateUSD.

	self
		shouldnt: [ 
			resourceController
				createCurrencyBasedOn: ( self
						  requestToPOST: '{
											"singularName":"United States Dollar",
											"pluralName":"United States Dollars",
											"subUnitDenominator":100,
											"ISO4217Code":"USN",
											"issueDate":"1792-04-02"}'
						  as: resourceController currencyVersion1dot0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError conflict.

	self assert: self systemUnderTest currencies size equals: 2
]

{ #category : #'tests - creating' }
CurrencyRESTfulControllerTest >> testCreateSeveralCurrencies [

	self testCreateUSD.
	self createJapaneseYen.

	self assert: self systemUnderTest currencies size equals: 2
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
		assertETag: response entityTag valueEquals: '0d02e4556127761030a96bf10fe8028291af8b1e';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'USD';
				assert: json singularName equals: 'United States Dollar';
				assert: json pluralName equals: 'United States Dollars';
				assert: json subUnitDenominator equals: 100;
				assert: json ISO4217Code equals: 'USD';
				assert: json issueDate equals: '1792-04-02';
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000';
				assertUrl: json links retireFromCirculation
				equals: self resourceUrl / '00000000-0000-0000-0000-000000000000' / 'retire-from-circulation'
			].
	self assertThereIsAtLeastOneCirculatingCurrency
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
		assertETag: response entityTag valueEquals: 'bcfd990afac64fc816888ef43565be5555ff3751';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'USD';
				assert: json singularName equals: 'United States Dollar';
				assert: json pluralName equals: 'United States Dollars';
				assert: json subUnitDenominator equals: 100;
				assert: json issueDate isNil;
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			].
	self assertThereIsAtLeastOneCirculatingCurrency
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
		assertETag: response entityTag valueEquals: '7d703fb32e9a7826b5c94aa626d1262301d6e1a7';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'USD';
				assert: json singularName equals: 'United States Dollar';
				assert: json pluralName equals: 'United States Dollars';
				assert: json subUnitDenominator isNil;
				assert: json issueDate isNil;
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			].
	self assertThereIsAtLeastOneCirculatingCurrency
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
		assertETag: response entityTag valueEquals: 'c6c9144cfafd590c1c7ef0a14d885b88cc6fba48';
		withJsonFromContentsIn: response do: [ :json | self assertMatchesJapaneseYenData: json ].

	self assertThereIsAtLeastOneCirculatingCurrency
]

{ #category : #'tests - querying' }
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
				equals: 'http://api.example.com/currencies/00000000-0000-0000-0000-000000000001';
				assertUrl: yen links retireFromCirculation
				equals: self resourceUrl / '00000000-0000-0000-0000-000000000001' / 'retire-from-circulation'.
			usd := items second.
			self
				assert: usd shortName equals: 'USD';
				assertUrl: usd selfLocation
				equals: 'http://api.example.com/currencies/00000000-0000-0000-0000-000000000000';
				assertUrl: usd links retireFromCirculation
				equals: self resourceUrl / '00000000-0000-0000-0000-000000000000' / 'retire-from-circulation'
			]
]

{ #category : #'tests - querying' }
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

{ #category : #'tests - querying' }
CurrencyRESTfulControllerTest >> testCurrencyIdentifiedBy [

	| createResponse response |

	createResponse := self createJapaneseYen.

	response := resourceController
		            currencyBasedOn: ( self
				              requestToGETResourceIdentifiedBy: self firstUUID
				              accepting: self unitOfAccountVersion1MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assertMediaType: response contentType
		equals: resourceController unitOfAccountVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		withJsonFromContentsIn: response do: [ :yen | 
			self
				assert: yen shortName equals: 'JPY';
				assertUrl: yen selfLocation
				equals: 'http://api.example.com/currencies/00000000-0000-0000-0000-000000000000'
			]
]

{ #category : #'tests - querying' }
CurrencyRESTfulControllerTest >> testCurrencyIdentifiedByNotFoundId [

	self
		should: [ 
			resourceController
				currencyBasedOn: ( self
						  requestToGETResourceIdentifiedBy: self firstUUID
						  accepting: self unitOfAccountVersion1MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError notFound
		withMessageText: 'There''s no currency identified by 00000000-0000-0000-0000-000000000000'
]

{ #category : #'tests - querying' }
CurrencyRESTfulControllerTest >> testCurrencyIdentifiedByWhenNotModified [

	| createResponse response |

	createResponse := self createJapaneseYen.

	response := resourceController
		            currencyBasedOn: ( self
				              requestToGETResourceIdentifiedBy: self firstUUID
				              accepting: self currencyVersion1MediaType
				              conditionalTo: createResponse entityTag )
		            within: self newHttpRequestContext.

	self assert: response isNotModified
]

{ #category : #'tests - querying' }
CurrencyRESTfulControllerTest >> testCurrencyIdentifiedByWhenNotModifiedButAskingAnotherMediaType [

	| createResponse response |

	createResponse := self createJapaneseYen.

	response := resourceController
		            currencyBasedOn: ( self
				              requestToGETResourceIdentifiedBy: self firstUUID
				              accepting: self unitOfAccountVersion1MediaType
				              conditionalTo: createResponse entityTag )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assertMediaType: response contentType
		equals: resourceController unitOfAccountVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		withJsonFromContentsIn: response do: [ :yen | 
			self
				assert: yen shortName equals: 'JPY';
				assertUrl: yen selfLocation
				equals: 'http://api.example.com/currencies/00000000-0000-0000-0000-000000000000'
			]
]

{ #category : #'tests - retiring' }
CurrencyRESTfulControllerTest >> testRetireYenFromCirculation [

	| createYenResponse |

	createYenResponse := self createJapaneseYen.
	
	self assertThereIsAtLeastOneCirculatingCurrency.
	
	self retireFromCirculationCurrencyIn: createYenResponse
]

{ #category : #'tests - retiring' }
CurrencyRESTfulControllerTest >> testRetireYenFromCirculationTwiceHasNoEffect [

	| createYenResponse |

	createYenResponse := self createJapaneseYen.
	self
		retireFromCirculationCurrencyIn: createYenResponse;
		retireFromCirculationCurrencyIn: createYenResponse
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testUpdateYenISO4217Code [

	| createRequest response |

	createRequest := self createJapaneseYen.

	response := resourceController
		            updateCurrencyBasedOn: ( self
				              requestToPATCHResourceIdentifiedBy: self firstUUID
				              with: '{"ISO4217Code":"YEN"}'
				              accepting: resourceController currencyVersion1dot0dot0MediaType
				              conditionalTo: createRequest entityTag )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assertMediaType: response contentType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: '5e5589132e77f7fc0b288a850410fc668972ccad';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'JPY';
				assert: json singularName equals: 'Japanese Yen';
				assert: json pluralName equals: 'Japanese Yen';
				assert: json subUnitDenominator equals: 1;
				assert: json ISO4217Code equals: 'YEN';
				assert: json issueDate equals: '1871-06-27';
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			]
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testUpdateYenIssueDate [

	| createRequest response |

	createRequest := self createJapaneseYen.

	response := resourceController
		            updateCurrencyBasedOn: ( self
				              requestToPATCHResourceIdentifiedBy: self firstUUID
				              with: '{"issueDate":"2022-04-01"}'
				              accepting: resourceController currencyVersion1dot0dot0MediaType
				              conditionalTo: createRequest entityTag )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assertMediaType: response contentType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: '0dd7ce12ffea3d0c49bc2bebdc78f7506bd1122d';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'JPY';
				assert: json singularName equals: 'Japanese Yen';
				assert: json pluralName equals: 'Japanese Yen';
				assert: json subUnitDenominator equals: 1;
				assert: json ISO4217Code equals: 'JPY';
				assert: json issueDate equals: '2022-04-01';
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			]
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testUpdateYenNames [

	| createRequest response |

	createRequest := self createJapaneseYen.

	response := resourceController
		            updateCurrencyBasedOn: ( self
				              requestToPATCHResourceIdentifiedBy: self firstUUID
				              with: '{"singularName":"Yen","pluralName":"Yenes"}'
				              accepting: resourceController currencyVersion1dot0dot0MediaType
				              conditionalTo: createRequest entityTag )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assertMediaType: response contentType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: '5729ccc94dd809fb70d99d263de6bbc8c2d45422';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'JPY';
				assert: json singularName equals: 'Yen';
				assert: json pluralName equals: 'Yenes';
				assert: json subUnitDenominator equals: 1;
				assert: json ISO4217Code equals: 'JPY';
				assert: json issueDate equals: '1871-06-27';
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			]
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testUpdateYenShortName [

	| createRequest response |

	createRequest := self createJapaneseYen.

	response := resourceController
		            updateCurrencyBasedOn: ( self
				              requestToPATCHResourceIdentifiedBy: self firstUUID
				              with: '{"shortName":"YEN"}'
				              accepting: resourceController currencyVersion1dot0dot0MediaType
				              conditionalTo: createRequest entityTag )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assertMediaType: response contentType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: '06ef85b3c987007b5f9eb7cf638d6eae6c82b15d';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'YEN';
				assert: json singularName equals: 'Japanese Yen';
				assert: json pluralName equals: 'Japanese Yen';
				assert: json subUnitDenominator equals: 1;
				assert: json ISO4217Code equals: 'JPY';
				assert: json issueDate equals: '1871-06-27';
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000';
				assertUrl: json links retireFromCirculation
				equals: self resourceUrl / '00000000-0000-0000-0000-000000000000' / 'retire-from-circulation'
			]
]

{ #category : #'tests - updating' }
CurrencyRESTfulControllerTest >> testUpdateYenSubUnitDenominator [

	| createRequest response |

	createRequest := self createJapaneseYen.

	response := resourceController
		            updateCurrencyBasedOn: ( self
				              requestToPATCHResourceIdentifiedBy: self firstUUID
				              with: '{"subUnitDenominator":10}'
				              accepting: resourceController currencyVersion1dot0dot0MediaType
				              conditionalTo: createRequest entityTag )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assertMediaType: response contentType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response cachingDirectives includes: 'Max-Age=86400';
		assertETag: response entityTag valueEquals: '6250ed72fd3e39bede3dc16262a227d2d9deeb6a';
		withJsonFromContentsIn: response do: [ :json | 
			self
				assert: json shortName equals: 'JPY';
				assert: json singularName equals: 'Japanese Yen';
				assert: json pluralName equals: 'Japanese Yen';
				assert: json subUnitDenominator equals: 10;
				assert: json ISO4217Code equals: 'JPY';
				assert: json issueDate equals: '1871-06-27';
				assertUrl: json selfLocation equals: self resourceUrl / '00000000-0000-0000-0000-000000000000'
			]
]

{ #category : #'private - support' }
CurrencyRESTfulControllerTest >> unitOfAccountVersion1MediaType [

	^ resourceController unitOfAccountVersion1dot0dot0MediaType copy version: '1'
]
