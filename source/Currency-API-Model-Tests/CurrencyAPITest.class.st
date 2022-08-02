Class {
	#name : #CurrencyAPITest,
	#superclass : #HTTPBasedRESTfulAPITest,
	#instVars : [
		'userStory',
		'controller'
	],
	#category : #'Currency-API-Model-Tests'
}

{ #category : #asserting }
CurrencyAPITest >> assertLastPathSegmentIsUUID: urlOrString [

	self shouldnt: [ UUID fromString: urlOrString asUrl lastPathSegment ] raise: Error
]

{ #category : #asserting }
CurrencyAPITest >> assertUrl: url beginsWith: shorterUrl [

	self assert: ( url asUrl printString beginsWith: shorterUrl asUrl printString )
]

{ #category : #private }
CurrencyAPITest >> controllersToInstall [

	^ { controller }
]

{ #category : #private }
CurrencyAPITest >> jsonEntityWith: aBlock ofType: mediaType [

	| data |

	data := NeoJSONObject new.
	aBlock value: data.

	^ ZnEntity with: ( NeoJSONWriter toString: data ) ofType: mediaType
]

{ #category : #private }
CurrencyAPITest >> newClientWithReader [

	^ self newClient
		  contentReader: [ :entity | NeoJSONObject fromString: entity contents ];
		  yourself
]

{ #category : #running }
CurrencyAPITest >> registerMainDBRepositoryProviderIn: repositorySystem [

	repositorySystem register: InMemoryRepositoryProvider new as: #mainDB
]

{ #category : #running }
CurrencyAPITest >> setUpAPI [

	self setUpController.
	super setUpAPI
]

{ #category : #running }
CurrencyAPITest >> setUpController [

	self setUpUserStory.
	controller := CurrencyRESTfulController workingWith: userStory rootSystem
]

{ #category : #running }
CurrencyAPITest >> setUpUserStory [

	userStory := PluggableUserStoryTest requiring: [ :test | 
		             | repositorySystem |
		             repositorySystem := RepositoryProviderSystem new.
		             self registerMainDBRepositoryProviderIn: repositorySystem.
		             test
			             registerSubsystem: CurrencyManagementSystem new;
			             registerSubsystem: repositorySystem
		             ].
	userStory setUp
]

{ #category : #'tests - creating' }
CurrencyAPITest >> testBadRequestOnCreate [

	self
		should: [ 
			self newClientWithReader
				url: self baseUrl / controller endpoint asUrl;
				entity: ( self
						  jsonEntityWith: [ :data | 
							  data
								  singularName: 'United States Dollar';
								  pluralName: 'United States Dollars';
								  subUnitDenominator: 100;
								  issueDate: '1792-04-02'
							  ]
						  ofType: controller currencyVersion1dot0dot0MediaType );
				setAccept: controller currencyVersion1dot0dot0MediaType;
				post
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			| json |

			self assert: error response isBadRequest.
			json := NeoJSONObject fromString: error response contents.
			self
				assert: json code equals: 400;
				assert: json message equals: 'Missing #shortName field.'
			]
]

{ #category : #'tests - creating' }
CurrencyAPITest >> testConflictOnCreate [

	self testCreateUSD.
	self
		should: [ 
			self newClientWithReader
				url: self baseUrl / controller endpoint asUrl;
				entity: ( self
						  jsonEntityWith: [ :data | 
							  data
								  singularName: 'United States Dollar';
								  ISO4217Code: 'USD';
								  issueDate: '1792-04-02'
							  ]
						  ofType: controller currencyVersion1dot0dot0MediaType );
				setAccept: controller currencyVersion1dot0dot0MediaType;
				post
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			| json |

			self assert: error response code equals: 409.
			json := NeoJSONObject fromString: error response contents.
			self
				assert: json code equals: 409;
				assert: json message equals: 'Something is in conflict with USD - United States Dollar'
			]
]

{ #category : #'tests - creating' }
CurrencyAPITest >> testCreateUSD [

	| client json |

	client := self newClientWithReader.

	json := client
		        url: self baseUrl / controller endpoint asUrl;
		        entity: ( self
				          jsonEntityWith: [ :data | 
					          data
						          singularName: 'United States Dollar';
						          pluralName: 'United States Dollars';
						          subUnitDenominator: 100;
						          ISO4217Code: 'USD';
						          issueDate: '1792-04-02'
					          ]
				          ofType: controller currencyVersion1dot0dot0MediaType );
		        setAccept: controller currencyVersion1dot0dot0MediaType;
		        post.

	self
		assert: client response isCreated;
		assertUrl: client response location beginsWith: self baseUrl / controller endpoint;
		assertLastPathSegmentIsUUID: client response location;
		assert: client response contentType equals: controller currencyVersion1dot0dot0MediaType.

	self
		assert: json shortName equals: 'USD';
		assert: json singularName equals: 'United States Dollar';
		assert: json pluralName equals: 'United States Dollars';
		assert: json subUnitDenominator equals: 100;
		assert: json ISO4217Code equals: 'USD';
		assert: json issueDate equals: '1792-04-02';
		assert: json links size equals: 2;
		assertUrl: json selfLocation equals: client response location;
		assertUrl: json links retireFromCirculation
		equals: json selfLocation asUrl / 'retire-from-circulation'.

	^ json
]

{ #category : #'tests - querying' }
CurrencyAPITest >> testCurrencies [

	| client json |

	self testCreateUSD.
	client := self newClientWithReader.

	json := client
		        url: self baseUrl / controller endpoint asUrl;
		        setAccept: controller unitOfAccountVersion1dot0dot0MediaType;
		        get.

	self
		assert: client response isSuccess;
		assert: client response contentType equals: controller unitOfAccountVersion1dot0dot0MediaType.

	self withTheOnlyOneIn: json items do: [ :usd | 
		self
			assert: usd shortName equals: 'USD';
			assert: usd singularName equals: 'United States Dollar';
			assert: usd pluralName equals: 'United States Dollars';
			assert: usd links size equals: 2;
			assertUrl: usd selfLocation beginsWith: self baseUrl / controller endpoint;
			assertLastPathSegmentIsUUID: usd selfLocation;
			assertUrl: usd links retireFromCirculation
			equals: usd selfLocation asUrl / 'retire-from-circulation'
		]
]

{ #category : #'tests - querying' }
CurrencyAPITest >> testCurrenciesASkingNotAcceptableMediaType [

	self
		should: [ 
			self newClient
				url: self baseUrl / controller endpoint asUrl;
				setAccept: ZnMimeType applicationXml;
				get
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			| json |

			self assert: error response code equals: 406.
			json := NeoJSONObject fromString: error response contents.
			self
				assert: json code equals: 406;
				assert: json message
				equals: 'Cannot generate a response entity with acceptable characteristics.';
				assert: json allowedMediaTypes size equals: 3;
				assert: json allowedMediaTypes includes: controller currencyVersion1dot0dot0MediaType asString;
				assert: json allowedMediaTypes
				includes: controller unitOfAccountVersion1dot0dot0MediaType asString;
				assert: json allowedMediaTypes
				includes: controller mediumOfExchangeVersion1dot0dot0MediaType asString
			]
]

{ #category : #'tests - querying' }
CurrencyAPITest >> testCurrencyIdentifiedBy [

	| client json |

	client := self newClientWithReader.

	json := client
		        url: self testCreateUSD selfLocation;
		        setAccept: controller unitOfAccountVersion1dot0dot0MediaType;
		        get.

	self
		assert: client response isSuccess;
		assert: client response contentType equals: controller unitOfAccountVersion1dot0dot0MediaType.

	self
		assert: json shortName equals: 'USD';
		assert: json singularName equals: 'United States Dollar';
		assert: json pluralName equals: 'United States Dollars';
		assert: json links size equals: 2;
		assertUrl: json selfLocation beginsWith: self baseUrl / controller endpoint;
		assertLastPathSegmentIsUUID: json selfLocation;
		assertUrl: json links retireFromCirculation
		equals: json selfLocation asUrl / 'retire-from-circulation'
]

{ #category : #'tests - querying' }
CurrencyAPITest >> testCurrencyIdentifiedByWhenNotModified [

	| client json |

	client := self newClientWithReader.

	json := client
		        url: self testCreateUSD selfLocation;
		        setAccept: controller unitOfAccountVersion1dot0dot0MediaType;
		        get.
	self assert: client response isSuccess.

	self
		should: [ 
			self newClientWithReader
				url: json selfLocation;
				setAccept: controller unitOfAccountVersion1dot0dot0MediaType;
				setIfNoneMatchTo: client response entityTag;
				get
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotModified ]
]

{ #category : #'tests - querying' }
CurrencyAPITest >> testCurrencyNotFound [

	self
		should: [ 
			self newClientWithReader
				url: self baseUrl / 'XXX';
				setAccept: controller unitOfAccountVersion1dot0dot0MediaType;
				get
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : #'tests - updating' }
CurrencyAPITest >> testPreconditionFailedOnUpdateCurrency [

	| usd |

	usd := self testCreateUSD.
	self
		should: [ 
			self newClient
				url: usd selfLocation;
				setIfMatchTo: '"XXX"' asEntityTag;
				entity: ( self
						  jsonEntityWith: [ :data | data singularName: 'Rucula' ]
						  ofType: controller currencyVersion1dot0dot0MediaType );
				setAccept: controller currencyVersion1dot0dot0MediaType;
				patch
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 412 ]
]

{ #category : #'tests - updating' }
CurrencyAPITest >> testPreconditionRequiredOnUpdateCurrency [

	| usd |

	usd := self testCreateUSD.
	self
		should: [ 
			self newClient
				url: usd selfLocation;
				entity: ( self
						  jsonEntityWith: [ :data | data singularName: 'Rucula' ]
						  ofType: controller currencyVersion1dot0dot0MediaType );
				setAccept: controller currencyVersion1dot0dot0MediaType;
				patch
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 428 ]
]

{ #category : #'tests - retiring' }
CurrencyAPITest >> testRetireFromCirculation [

	| client json usd |

	usd := self testCreateUSD.

	client := self newClient.
	client
		url: usd links retireFromCirculation;
		put.

	self
		assert: client response isNoContent;
		deny: client response hasEntity.

	client := self newClientWithReader.

	json := client
		        url: usd selfLocation;
		        setAccept: controller unitOfAccountVersion1dot0dot0MediaType;
		        get.

	self
		assert: client response isSuccess;
		assert: client response contentType equals: controller unitOfAccountVersion1dot0dot0MediaType.

	self
		assert: json shortName equals: 'USD';
		assert: json singularName equals: 'United States Dollar';
		assert: json pluralName equals: 'United States Dollars';
		assert: json links size equals: 1;
		assertUrl: json selfLocation beginsWith: self baseUrl / controller endpoint;
		assertLastPathSegmentIsUUID: json selfLocation
]

{ #category : #'tests - retiring' }
CurrencyAPITest >> testRetireFromCirculationWhenNotFound [

	self
		should: [ 
			self newClient
				url: self baseUrl / controller endpoint / 'XXX' / 'retire-from-circulation';
				put
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : #'tests - creating' }
CurrencyAPITest >> testUnprocessableEntityOnCreate [

	self
		should: [ 
			self newClientWithReader
				url: self baseUrl / controller endpoint asUrl;
				entity: ( self
						  jsonEntityWith: [ :data | 
							  data
								  singularName: '';
								  pluralName: 'United States Dollars';
								  subUnitDenominator: 100;
								  ISO4217Code: 'USD';
								  issueDate: '1792-04-02'
							  ]
						  ofType: controller currencyVersion1dot0dot0MediaType );
				setAccept: controller currencyVersion1dot0dot0MediaType;
				post
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			| json |

			self assert: error response code equals: 422.
			json := NeoJSONObject fromString: error response contents.
			self
				assert: json code equals: 422;
				assert: json message equals: 'A currency can''t have an empty name'
			]
]

{ #category : #'tests - creating' }
CurrencyAPITest >> testUnsupportedMediaType [

	self
		should: [ 
			self newClient
				url: self baseUrl / controller endpoint asUrl;
				contents: 'Bad';
				setAccept: controller currencyVersion1dot0dot0MediaType;
				post
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 415 ]
]

{ #category : #'tests - updating' }
CurrencyAPITest >> testUpdateCurrency [

	| client json usd getResponse |

	usd := self testCreateUSD.

	getResponse := self newClient
		               url: usd selfLocation;
		               setAccept: controller currencyVersion1dot0dot0MediaType;
		               get;
		               response.

	client := self newClient.
	client
		url: usd selfLocation;
		setIfMatchTo: getResponse entityTag;
		entity: ( self
				  jsonEntityWith: [ :data | data singularName: 'Rucula' ]
				  ofType: controller currencyVersion1dot0dot0MediaType );
		setAccept: controller currencyVersion1dot0dot0MediaType;
		patch.

	self assert: client response isSuccess.

	client := self newClientWithReader.

	json := client
		        url: usd selfLocation;
		        setAccept: controller unitOfAccountVersion1dot0dot0MediaType;
		        get.

	self
		assert: client response isSuccess;
		assert: client response contentType equals: controller unitOfAccountVersion1dot0dot0MediaType.

	self
		assert: json shortName equals: 'USD';
		assert: json singularName equals: 'Rucula';
		assert: json pluralName equals: 'United States Dollars';
		assert: json links size equals: 2;
		assertUrl: json selfLocation beginsWith: self baseUrl / controller endpoint;
		assertLastPathSegmentIsUUID: json selfLocation
]
