"
A CurrencyTest is a test class for testing the behavior of Currency
"
Class {
	#name : #CurrencyTest,
	#superclass : #TestCase,
	#category : #'Currency-Model-Tests'
}

{ #category : #'tests - instance creation failed' }
CurrencyTest >> testCantCreateCurrencyWithEmptyPluralName [

	self
		should: [ 
			Currency
				shortNamed: 'MENEM'
				singularNamed: 'Menem trucho'
				pluralNamed: ''
				subUnitDenominator: 100
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed
		withMessageText: 'A currency can''t have an empty name'
]

{ #category : #'tests - instance creation failed' }
CurrencyTest >> testCantCreateCurrencyWithEmptySingularName [

	self
		should: [ 
			Currency
				shortNamed: 'MENEM'
				singularNamed: ''
				pluralNamed: 'Menem truchos'
				subUnitDenominator: 100
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed
		withMessageText: 'A currency can''t have an empty name'
]

{ #category : #'tests - instance creation failed' }
CurrencyTest >> testCantCreateCurrencyWithFractionalSubUnitDenominator [

	self
		should: [ 
			Currency
				shortNamed: 'MENEM'
				singularNamed: 'Menem trucho'
				pluralNamed: 'Menem truchos'
				subUnitDenominator: 1 / 100
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed
		withMessageText: 'The sub-unit denominator must be a strictly positive integer'
]

{ #category : #'tests - instance creation failed' }
CurrencyTest >> testCantCreateCurrencyWithInvalidISOCode [

	self
		should: [ 
			Currency
				singularNamed: 'Menem trucho'
				pluralNamed: 'Menem truchos'
				subUnitDenominator: 1
				withISO4217Code: 'ME'
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed withMessageText:
			'A currency short name must have between 3 and 6 letters. ISO 4217 code must have exactly three letters';
		should: [ 
			Currency
				singularNamed: 'Menem trucho'
				pluralNamed: 'Menem truchos'
				subUnitDenominator: 1
				withISO4217Code: 'MENE'
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed withMessageText: 'ISO 4217 code must have exactly three letters'
]

{ #category : #'tests - instance creation failed' }
CurrencyTest >> testCantCreateCurrencyWithInvalidShortName [

	self
		should: [ 
			Currency
				shortNamed: 'ME'
				singularNamed: 'Menem trucho'
				pluralNamed: 'Menem truchos'
				subUnitDenominator: 1
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed withMessageText:
			'A currency short name must have between 3 and 6 letters';
		should: [ 
			Currency
				shortNamed: 'MENEMTR'
				singularNamed: 'Menem trucho'
				pluralNamed: 'Menem truchos'
				subUnitDenominator: 1
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed withMessageText:
			'A currency short name must have between 3 and 6 letters';
		shouldnt: [ 
			Currency
				shortNamed: 'MENEMT'
				singularNamed: 'Menem trucho'
				pluralNamed: 'Menem truchos'
				subUnitDenominator: 1
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed
]

{ #category : #'tests - instance creation failed' }
CurrencyTest >> testCantCreateCurrencyWithNegativeSubUnitDenominator [

	self
		should: [ 
			Currency
				shortNamed: 'MENEM'
				singularNamed: 'Menem trucho'
				pluralNamed: 'Menem truchos'
				subUnitDenominator: -1
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed
		withMessageText: 'The sub-unit denominator must be a strictly positive integer'
]

{ #category : #'tests - instance creation failed' }
CurrencyTest >> testCantCreateCurrencyWithZeroSubUnitDenominator [

	self
		should: [ 
			Currency
				shortNamed: 'MENEM'
				singularNamed: 'Menem trucho'
				pluralNamed: 'Menem truchos'
				subUnitDenominator: 0
				issuedOn: April second , 1991
			]
		raise: InstanceCreationFailed
		withMessageText: 'The sub-unit denominator must be a strictly positive integer'
]

{ #category : #tests }
CurrencyTest >> testCreatingAbkhazianApsar [

	"The apsar is a currency of Abkhazia. As the state is unrecognized
	or partially recognized 	it doesn't have an ISO code assigned."

	| currency |

	currency := Currency
		            shortNamed: 'APSAR'
		            singularNamed: 'Apsar'
		            pluralNamed: 'Apsark'
		            subUnitDenominator: 1
		            issuedOn: September twentysixth , 2008.

	self
		assert: currency shortName equals: 'APSAR';
		assert: currency singularName equals: 'Apsar';
		assert: currency pluralName equals: 'Apsark';
		assert: currency issueDate equals: September twentysixth , 2008;
		assert: currency subUnitDenominator equals: 1;
		deny: currency hasISO4217Code.

	currency withISO4217CodeDo: [ :code | self fail ].

	self assert: currency printString equals: 'APSAR - Apsar'
]

{ #category : #tests }
CurrencyTest >> testCreatingJapaneseYen [

	"The Japanese Yen has a few singularities:
	- The language of this currency do not have a morphological plural distinction.
	- Do not have minor units, like cents in other currencies.	"

	| currency |

	currency := Currency
		            named: 'Japanese Yen'
		            withISO4217Code: 'JPY'
		            issuedOn: June twentyseventh , 1871.

	self
		assert: currency shortName equals: 'JPY';
		assert: currency singularName equals: 'Japanese Yen';
		assert: currency pluralName equals: 'Japanese Yen';
		assert: currency issueDate equals: June twentyseventh , 1871;
		assert: currency subUnitDenominator equals: 1;
		assert: currency hasISO4217Code.

	currency withISO4217CodeDo: [ :code | self assert: code equals: 'JPY' ].

	self assert: currency printString equals: 'JPY - Japanese Yen'
]

{ #category : #tests }
CurrencyTest >> testCreatingUnitedStatesDollar [

	| currency |

	currency := Currency
		            singularNamed: 'United States Dollar'
		            pluralNamed: 'United States Dollars'
		            subUnitDenominator: 100
		            withISO4217Code: 'USD'
		            issuedOn: April second , 1792.

	self
		assert: currency shortName equals: 'USD';
		assert: currency singularName equals: 'United States Dollar';
		assert: currency pluralName equals: 'United States Dollars';
		assert: currency issueDate equals: April second , 1792;
		assert: currency subUnitDenominator equals: 100;
		assert: currency hasISO4217Code.

	currency withISO4217CodeDo: [ :code | self assert: code equals: 'USD' ].

	self assert: currency printString equals: 'USD - United States Dollar'
]

{ #category : #tests }
CurrencyTest >> testUpdateCurrency [

	| currency yen |

	currency := Currency
		            singularNamed: 'United States Dollar'
		            pluralNamed: 'United States Dollars'
		            subUnitDenominator: 100
		            withISO4217Code: 'USD'
		            issuedOn: April second , 1792.

	yen := Currency named: 'Japanese Yen' withISO4217Code: 'JPY' issuedOn: June twentyseventh , 1871.

	currency synchronizeWith: yen.

	self
		assert: currency shortName equals: 'JPY';
		assert: currency singularName equals: 'Japanese Yen';
		assert: currency pluralName equals: 'Japanese Yen';
		assert: currency issueDate equals: June twentyseventh , 1871;
		assert: currency subUnitDenominator equals: 1;
		assert: currency hasISO4217Code.

	currency withISO4217CodeDo: [ :code | self assert: code equals: 'JPY' ].

	self assert: currency printString equals: 'JPY - Japanese Yen'
]
