Class {
	#name : #CurrencyManagementSystem,
	#superclass : #SubsystemImplementation,
	#instVars : [
		'currencies'
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

{ #category : #querying }
CurrencyManagementSystem >> allCurrencies [

	^ currencies findAllMatching: [ :currency | true ] sortedBy: #shortName ascending
]

{ #category : #querying }
CurrencyManagementSystem >> currencies [

	^ currencies findAllMatching: [ :currency | currency isCirculating ] sortedBy: #shortName ascending
]

{ #category : #installing }
CurrencyManagementSystem >> dependencies [

	^ #(  )
]

{ #category : #installing }
CurrencyManagementSystem >> implementedInterfaces [

	^ #( CurrencyManagementSystem )
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

	^ currencies store: ( StatusAwareCurrency basedOn: aCurrency )
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
