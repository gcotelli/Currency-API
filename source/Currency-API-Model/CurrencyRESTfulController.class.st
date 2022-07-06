Class {
	#name : #CurrencyRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'rootSystem',
		'currenciesRequestHandler'
	],
	#category : #'Currency-API-Model'
}

{ #category : #'instance creation' }
CurrencyRESTfulController class >> workingWith: aCompositeSystem [

	^ self new initializeWorkingWith: aCompositeSystem
]

{ #category : #'private - encoding' }
CurrencyRESTfulController >> configureEncodingForCurrencyIn: aNeoJSONWriter [

	aNeoJSONWriter for: #Currency do: [ :mapping | 
		mapping
			mapProperty: #shortName getter: #shortName;
			mapProperty: #singularName getter: #singularName;
			mapProperty: #pluralName getter: #pluralName;
			mapProperty: #ISO4217Code
			getter: [ :currency | currency withISO4217CodeDo: [ :code | code ] ifUndefined: [ nil ] ];
			mapProperty: #issueDate getter: #issueDate;
			mapProperty: #subUnitDenominator getter: #subUnitDenominator
		]
]

{ #category : #API }
CurrencyRESTfulController >> currenciesBasedOn: httpRequest within: requestContext [

	^ currenciesRequestHandler
		  from: httpRequest
		  within: requestContext
		  getCollection: [ ( rootSystem >> #CurrencyManagementSystem ) currencies ]
]

{ #category : #'accessing - media types' }
CurrencyRESTfulController >> currencyVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'currency' vendoredBy: 'gcotelli' version: '1.0.0'
]

{ #category : #initialization }
CurrencyRESTfulController >> initializeCurrenciesRequestHandler [

	currenciesRequestHandler := RESTfulRequestHandlerBuilder new
		                            handling: 'currencies'
		                            locatingResourcesWith: [ :currency :requestContext | 
			                            self identifierOf: currency ]
		                            extractingIdentifierWith: [ :httpRequest | 
			                            self identifierIn: httpRequest ];
		                            beHypermediaDrivenBy: [ :builder :currency :requestContext :currencyLocation | 
			                             ];
		                            paginateCollectionsWithDefaultLimit: 100;
		                            whenResponding: self currencyVersion1dot0dot0MediaType
		                            encodeToJsonApplying: [ :currency :requestContext :writer | 
			                            self configureEncodingForCurrencyIn: writer ]
		                            as: #Currency;
		                            whenResponding: self unitOfAccountVersion1dot0dot0MediaType
		                            encodeToJsonApplying: [ :currency :requestContext :writer | 
			                            self configureEncodingForUnitOfAccountIn: writer ];
		                            whenResponding: self mediumOfExchangeVersion1dot0dot0MediaType
		                            encodeToJsonApplying: [ :currency :requestContext :writer | 
			                            self configureEncodingForMediumOfExchangeIn: writer ];
		                            createEntityTagHashingEncodedResource;
		                            directCachingWith: [ :caching | caching beStaleAfter: 1 day ];
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

	^ currenciesRequestHandler
]

{ #category : #'accessing - media types' }
CurrencyRESTfulController >> unitOfAccountVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'unit-of-account' vendoredBy: 'gcotelli' version: '1.0.0'
]
