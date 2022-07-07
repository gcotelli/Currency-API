Class {
	#name : #CurrencyRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'rootSystem',
		'requestHandler'
	],
	#category : #'Currency-API-Model'
}

{ #category : #'instance creation' }
CurrencyRESTfulController class >> workingWith: aCompositeSystem [

	^ self new initializeWorkingWith: aCompositeSystem
]

{ #category : #private }
CurrencyRESTfulController >> addStateRelatedLinksFor: currency locatedAt: currencyLocation to: builder [

	( self system isCirculating: currency ) then: [ 
		builder addLink: currencyLocation / 'retire-from-circulation' relatedTo: 'retireFromCirculation' ]
]

{ #category : #'private - encoding' }
CurrencyRESTfulController >> configure: aNeoJSONWriter toEncodeAsCurrencyWithin: requestContext [

	aNeoJSONWriter
		for: #Currency do: [ :mapping | 
			mapping
				mapProperty: #shortName getter: #shortName;
				mapProperty: #singularName getter: #singularName;
				mapProperty: #pluralName getter: #pluralName;
				mapProperty: #ISO4217Code
				getter: [ :currency | currency withISO4217CodeDo: [ :code | code ] ifUndefined: [ nil ] ];
				mapProperty: #issueDate getter: #issueDate;
				mapProperty: #subUnitDenominator getter: #subUnitDenominator;
				mapAsHypermediaControls: [ :currency | requestContext hypermediaControlsFor: currency ]
			];
		for: Date customDo: [ :mapping | mapping encoder: [ :date | date yyyymmdd ] ]
]

{ #category : #'private - encoding' }
CurrencyRESTfulController >> configure: aNeoJSONWriter toEncodeAsMediumOfExchangeWithin: requestContext [

	aNeoJSONWriter for: #MediumOfExchange do: [ :mapping | 
		mapping
			mapProperty: #shortName getter: #shortName;
			mapProperty: #singularName getter: #singularName;
			mapProperty: #pluralName getter: #pluralName;
			mapProperty: #subUnitDenominator getter: #subUnitDenominator;
			mapAsHypermediaControls: [ :currency | requestContext hypermediaControlsFor: currency ]
		]
]

{ #category : #'private - encoding' }
CurrencyRESTfulController >> configure: aNeoJSONWriter toEncodeAsUnitOfAccountWithin: requestContext [

	aNeoJSONWriter for: #UnitOfAccount do: [ :mapping | 
		mapping
			mapProperty: #shortName getter: #shortName;
			mapProperty: #singularName getter: #singularName;
			mapProperty: #pluralName getter: #pluralName;
			mapAsHypermediaControls: [ :currency | requestContext hypermediaControlsFor: currency ]
		]
]

{ #category : #API }
CurrencyRESTfulController >> createCurrencyBasedOn: httpRequest within: requestContext [

	^ requestHandler
		  withRepresentationIn: httpRequest
		  within: requestContext
		  createResourceWith: [ :json | Currency basedOn: json ]
		  thenDo: [ :currency | self system storeCurrency: currency ]
]

{ #category : #API }
CurrencyRESTfulController >> currenciesBasedOn: httpRequest within: requestContext [

	^ requestHandler from: httpRequest within: requestContext getCollection: [ self system currencies ]
]

{ #category : #private }
CurrencyRESTfulController >> currencyBasedOn: json defaultingTo: currency [

	json at: #shortName ifAbsent: [ json shortName: currency shortName ].
	json at: #singularName ifAbsent: [ json singularName: currency singularName ].
	json at: #pluralName ifAbsent: [ json pluralName: currency pluralName ].
	json at: #issueDate ifAbsent: [ json issueDate: currency issueDate yyyymmdd ].
	json at: #ISO4217Code ifAbsent: [ currency withISO4217CodeDo: [ :code | json ISO4217Code: code ] ].

	^ Currency basedOn: json
]

{ #category : #API }
CurrencyRESTfulController >> currencyBasedOn: httpRequest within: requestContext [

	^ requestHandler
		  from: httpRequest
		  within: requestContext
		  get: [ :id | self system currencyIdentifiedBy: id ]
]

{ #category : #'accessing - media types' }
CurrencyRESTfulController >> currencyVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'currency' vendoredBy: 'gcotelli' version: '1.0.0'
]

{ #category : #initialization }
CurrencyRESTfulController >> initializeCurrenciesRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		                  handling: 'currencies'
		                  locatingResourcesWith: [ :currency :requestContext | 
			                  self system identifierOf: currency ]
		                  extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		                  beHypermediaDrivenBy: [ :builder :currency :requestContext :currencyLocation | 
			                  self addStateRelatedLinksFor: currency locatedAt: currencyLocation to: builder ];
		                  decodeToNeoJSONObjectWhenAccepting: self currencyVersion1dot0dot0MediaType;
		                  whenResponding: self currencyVersion1dot0dot0MediaType
		                  encodeToJsonApplying: [ :currency :requestContext :writer | 
			                  self configure: writer toEncodeAsCurrencyWithin: requestContext ]
		                  as: #Currency;
		                  whenResponding: self unitOfAccountVersion1dot0dot0MediaType
		                  encodeToJsonApplying: [ :currency :requestContext :writer | 
			                  self configure: writer toEncodeAsUnitOfAccountWithin: requestContext ]
		                  as: #UnitOfAccount;
		                  whenResponding: self mediumOfExchangeVersion1dot0dot0MediaType
		                  encodeToJsonApplying: [ :currency :requestContext :writer | 
			                  self configure: writer toEncodeAsMediumOfExchangeWithin: requestContext ]
		                  as: #MediumOfExchange;
		                  createEntityTagHashingEncodedResource;
		                  directCachingWith: [ :caching | caching beStaleAfter: 1 day ];
		                  handleExceptionsApplying: [ :handler | 
			                  handler addAsUnprocessableEntityError: DateError ];
		                  build
]

{ #category : #initialization }
CurrencyRESTfulController >> initializeWorkingWith: aCompositeSystem [

	rootSystem := aCompositeSystem.
	self initializeCurrenciesRequestHandler
]

{ #category : #'accessing - media types' }
CurrencyRESTfulController >> mediumOfExchangeVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'medium-of-exchange' vendoredBy: 'gcotelli' version: '1.0.0'
]

{ #category : #private }
CurrencyRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #API }
CurrencyRESTfulController >> retireFromCirculationBasedOn: httpRequest within: requestContext [

	^ requestHandler
		  from: httpRequest
		  within: requestContext
		  get: [ :id | self system currencyIdentifiedBy: id ]
		  thenDo: [ :currency | self system retireFromCirculation: currency ]
]

{ #category : #private }
CurrencyRESTfulController >> system [

	^ rootSystem >> #CurrencyManagementSystem
]

{ #category : #'accessing - media types' }
CurrencyRESTfulController >> unitOfAccountVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'unit-of-account' vendoredBy: 'gcotelli' version: '1.0.0'
]

{ #category : #API }
CurrencyRESTfulController >> updateCurrencyBasedOn: httpRequest with: requestContext [

	^ requestHandler
		  from: httpRequest
		  within: requestContext
		  get: [ :id | self system currencyIdentifiedBy: id ]
		  thenUpdateWith: [ :currency :json | 
			  self system
				  updateCurrency: currency
				  with: ( self currencyBasedOn: json defaultingTo: currency ) ]
]
