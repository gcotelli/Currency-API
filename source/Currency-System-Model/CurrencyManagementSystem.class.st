Class {
	#name : #CurrencyManagementSystem,
	#superclass : #SubsystemImplementation,
	#instVars : [
		'currencies',
		'uniqueIdGenerator'
	],
	#category : #'Currency-System-Model'
}

{ #category : #'class initialization' }
CurrencyManagementSystem class >> initialize [

	<ignoreForCoverage>
	Kepler
		registerInterfaceAt: #CurrencyManagementSystem
		named: 'Currency Management'
		declaring:
			#( #currencies #allCurrencies #'withCurrencyMatching:do:else' #storeCurrency: #updateCurrency:with:
			   #retireFromCirculation: )
]

{ #category : #'instance creation' }
CurrencyManagementSystem class >> new [

	^ self using: UUIDGenerator default
]

{ #category : #'instance creation' }
CurrencyManagementSystem class >> using: anUniqueIdGenerator [

	^ super new initializeUsing: anUniqueIdGenerator
]

{ #category : #querying }
CurrencyManagementSystem >> allCurrencies [

	^ currencies findAllMatching: [ :currency | true ] sortedBy: #shortName ascending
]

{ #category : #querying }
CurrencyManagementSystem >> currencies [

	^ currencies findAllMatching: [ :currency | currency isCirculating ] sortedBy: #shortName ascending
]

{ #category : #querying }
CurrencyManagementSystem >> currencyIdentifiedBy: anIdentifier [

	^ self
		  withCurrencyMatching: [ :currency :criteria | currency uuid = anIdentifier ]
		  do: #yourself
		  else: [ 
			  ObjectNotFound signal:
				  ( 'There''s no currency identified by <1p>' expandMacrosWith: anIdentifier ) ]
]

{ #category : #installing }
CurrencyManagementSystem >> dependencies [

	^ #(  )
]

{ #category : #querying }
CurrencyManagementSystem >> identifierOf: aStatusAwareCurrency [

	^ aStatusAwareCurrency uuid
]

{ #category : #installing }
CurrencyManagementSystem >> implementedInterfaces [

	^ #( CurrencyManagementSystem )
]

{ #category : #initialization }
CurrencyManagementSystem >> initializeUsing: anUniqueIdGenerator [

	uniqueIdGenerator := anUniqueIdGenerator
]

{ #category : #testing }
CurrencyManagementSystem >> isCirculating: aStatusAwareCurrency [

	^ aStatusAwareCurrency isCirculating
]

{ #category : #accessing }
CurrencyManagementSystem >> name [

	^ 'Currency Management'
]

{ #category : #installing }
CurrencyManagementSystem >> resolveDependencies [

	super resolveDependencies.
	currencies := InMemoryRepository checkingConflictsAccordingTo:
		              ( CriteriaBasedConflictCheckingStrategy forSingleAspectMatching: #shortName )
]

{ #category : #management }
CurrencyManagementSystem >> retireFromCirculation: aStatusAwareCurrency [

	currencies update: aStatusAwareCurrency with: aStatusAwareCurrency asNonCirculating
]

{ #category : #management }
CurrencyManagementSystem >> storeCurrency: aCurrency [

	^ currencies store: ( StatusAwareCurrency basedOn: aCurrency identifiedBy: uniqueIdGenerator next )
]

{ #category : #management }
CurrencyManagementSystem >> updateCurrency: aStatusAwareCurrency with: aCurrency [

	^ currencies update: aStatusAwareCurrency with: ( aStatusAwareCurrency basedOn: aCurrency )
]

{ #category : #querying }
CurrencyManagementSystem >> withCurrencyMatching: aCriteria do: foundBlock else: noneBlock [

	^ currencies
		  withOneMatching: aCriteria
		  sortedBy: #shortName ascending
		  do: foundBlock
		  else: noneBlock
]
