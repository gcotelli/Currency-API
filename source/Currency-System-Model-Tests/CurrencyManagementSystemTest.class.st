"
A CurrencyManagementSystemTest is a test class for testing the behavior of CurrencyManagementSystem
"
Class {
	#name : #CurrencyManagementSystemTest,
	#superclass : #SystemBasedUserStoryTest,
	#instVars : [
		'austral'
	],
	#category : #'Currency-System-Model-Tests'
}

{ #category : #accessing }
CurrencyManagementSystemTest class >> resources [

	^ { CurrencyTestResource }
]

{ #category : #running }
CurrencyManagementSystemTest >> setUp [

	super setUp.
	austral := Currency
		           singularNamed: 'Austral'
		           pluralNamed: 'Australes'
		           subUnitDenominator: 100
		           withISO4217Code: 'ARA'
		           issuedOn: June fifteenth , 1985
]

{ #category : #'private - running' }
CurrencyManagementSystemTest >> setUpRequirements [

	self registerSubsystem: CurrencyManagementSystem new
]

{ #category : #'private - accessing' }
CurrencyManagementSystemTest >> systemUnderTest [

	^ rootSystem >> #CurrencyManagementSystem
]

{ #category : #'tests - storing' }
CurrencyManagementSystemTest >> testCantStoreCurrencyWithTheSameShortName [

	self assert: self systemUnderTest currencies isEmpty.

	self systemUnderTest storeCurrency: self usd.
	self
		should: [ 
			self systemUnderTest storeCurrency:
				( Currency named: 'Dollar' withISO4217Code: 'USD' issuedOn: January first , 2022 )
			]
		raise: ConflictingObjectFound
		withMessageText: 'Something is in conflict with USD - Dollar'
]

{ #category : #'tests - storing' }
CurrencyManagementSystemTest >> testCantStoreTheSameCurrencyTwice [

	self assert: self systemUnderTest currencies isEmpty.

	self systemUnderTest storeCurrency: self usd.
	self
		should: [ self systemUnderTest storeCurrency: self usd ]
		raise: ConflictingObjectFound
		withMessageText: 'Something is in conflict with USD - United States Dollar'
]

{ #category : #'tests - updating' }
CurrencyManagementSystemTest >> testCantUpdateCurrencyWithConflictingData [

	self systemUnderTest
		storeCurrency: austral;
		storeCurrency: self usd.

	self systemUnderTest
		withCurrencyMatching: [ :currency | currency shortName = austral shortName ]
		do: [ :currency | 
			self
				should: [ self systemUnderTest updateCurrency: currency with: self usd ]
				raise: ConflictingObjectFound
				withMessageText: 'Something is in conflict with USD - United States Dollar'
			]
		else: [ self fail ]
]

{ #category : #'tests - updating' }
CurrencyManagementSystemTest >> testCantUpdateNonCirculatingCurrencyWithConflictingData [

	self testRetireCurrencyFromCirculation.
	self systemUnderTest storeCurrency: self usd.

	self systemUnderTest
		withCurrencyMatching: [ :currency | currency shortName = austral shortName ]
		do: [ :currency | 
			self
				should: [ self systemUnderTest updateCurrency: currency with: self usd ]
				raise: ConflictingObjectFound
				withMessageText: 'Something is in conflict with USD - United States Dollar'
			]
		else: [ self fail ]
]

{ #category : #'tests - querying' }
CurrencyManagementSystemTest >> testCurrencies [

	self assert: self systemUnderTest currencies isEmpty.

	self systemUnderTest storeCurrency: self usd.

	self
		withTheOnlyOneIn: self systemUnderTest currencies
		do: [ :currency | self assert: currency shortName equals: self usd shortName ]
]

{ #category : #'tests - querying' }
CurrencyManagementSystemTest >> testName [

	self assert: self systemUnderTest name equals: 'Currency Management'
]

{ #category : #'tests - retiring' }
CurrencyManagementSystemTest >> testRetireCurrencyFromCirculation [

	self systemUnderTest storeCurrency: austral.

	self
		withTheOnlyOneIn: self systemUnderTest allCurrencies
		do: [ :currency | self assert: currency shortName equals: austral shortName ].

	self withTheOnlyOneIn: self systemUnderTest currencies do: [ :currency | 
		self assert: currency shortName equals: austral shortName.

		self systemUnderTest retireCurrencyFromCirculation: currency
		].

	self assert: self systemUnderTest currencies isEmpty.
	self
		withTheOnlyOneIn: self systemUnderTest allCurrencies
		do: [ :currency | self assert: currency shortName equals: austral shortName ]
]

{ #category : #'tests - storing' }
CurrencyManagementSystemTest >> testStoreCurrenciesWithTheSameName [

	self assert: self systemUnderTest currencies isEmpty.

	self systemUnderTest storeCurrency: self usd.
	self systemUnderTest storeCurrency:
		( Currency named: self usd singularName withISO4217Code: 'USN' issuedOn: April first , 2000 ).

	self systemUnderTest currencies in: [ :currencies | 
		self
			assert: currencies size equals: 2;
			assert: currencies first shortName equals: self usd shortName;
			assert: currencies second shortName equals: 'USN'
		]
]

{ #category : #'tests - storing' }
CurrencyManagementSystemTest >> testStoreSeveralCurrencies [

	self assert: self systemUnderTest currencies isEmpty.

	self systemUnderTest storeCurrency: self usd.
	self systemUnderTest storeCurrency: self yen.

	self systemUnderTest currencies in: [ :currencies | 
		self
			assert: currencies size equals: 2;
			assert: currencies first shortName equals: self yen shortName;
			assert: currencies second shortName equals: self usd shortName
		]
]

{ #category : #'tests - updating' }
CurrencyManagementSystemTest >> testUpdateCurrency [

	self systemUnderTest storeCurrency: austral.

	self systemUnderTest
		withCurrencyMatching: [ :currency | currency shortName = austral shortName ]
		do: [ :currency | self systemUnderTest updateCurrency: currency with: self usd ]
		else: [ self fail ].

	self
		withTheOnlyOneIn: self systemUnderTest currencies
		do: [ :currency | self assert: currency shortName equals: self usd shortName ]
]

{ #category : #'tests - updating' }
CurrencyManagementSystemTest >> testUpdateNonCirculatingCurrency [

	self testRetireCurrencyFromCirculation.

	self systemUnderTest
		withCurrencyMatching: [ :currency | currency shortName = austral shortName ]
		do: [ :currency | self systemUnderTest updateCurrency: currency with: self usd ]
		else: [ self fail ].

	self assert: self systemUnderTest currencies isEmpty.

	self
		withTheOnlyOneIn: self systemUnderTest allCurrencies
		do: [ :currency | self assert: currency shortName equals: self usd shortName ]
]

{ #category : #'tests - querying' }
CurrencyManagementSystemTest >> testWithCurrencyMatchingDoElse [

	self systemUnderTest storeCurrency: self usd.

	self systemUnderTest
		withCurrencyMatching: [ :currency | currency shortName = self usd shortName ]
		do: [ :currency | 
			self
				assert: currency shortName equals: self usd shortName;
				assert: currency singularName equals: self usd singularName;
				assert: currency pluralName equals: self usd pluralName;
				assert: currency issueDate equals: self usd issueDate;
				assert: currency subUnitDenominator equals: self usd subUnitDenominator;
				assert: currency hasISO4217Code.

			currency
				withISO4217CodeDo: [ :code | self assert: code equals: self usd shortName ];
				withISO4217CodeDo: [ :code | self assert: code equals: self usd shortName ]
				ifUndefined: [ self fail ].

			self assert: currency printString equals: self usd printString
			]
		else: [ self fail ]
]

{ #category : #'tests - querying' }
CurrencyManagementSystemTest >> testWithCurrencyMatchingDoElseWhenEmpty [

	| noCurrencyWasFound |

	noCurrencyWasFound := false.

	self systemUnderTest
		withCurrencyMatching: [ :currency | true ]
		do: [ :currency | self fail ]
		else: [ noCurrencyWasFound := true ].

	self assert: noCurrencyWasFound
]

{ #category : #'tests - querying' }
CurrencyManagementSystemTest >> testWithCurrencyMatchingDoElseWhenNotMatching [

	| noCurrencyWasFound |

	noCurrencyWasFound := false.

	self systemUnderTest storeCurrency: self usd.

	self systemUnderTest
		withCurrencyMatching: [ :currency | currency shortName = self yen shortName ]
		do: [ :currency | self fail ]
		else: [ noCurrencyWasFound := true ].

	self assert: noCurrencyWasFound
]

{ #category : #'private - accessing' }
CurrencyManagementSystemTest >> usd [

	^ CurrencyTestResource current usd
]

{ #category : #'private - accessing' }
CurrencyManagementSystemTest >> yen [

	^ CurrencyTestResource current yen
]
