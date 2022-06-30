Class {
	#name : #Currency,
	#superclass : #Object,
	#instVars : [
		'shortName',
		'singularName',
		'pluralName',
		'subUnitDenominator',
		'iso4217CodeOptional',
		'issueDate'
	],
	#category : #'Currency-Model'
}

{ #category : #'instance creation' }
Currency class >> named: aName withISO4217Code: anISO4217Code issuedOn: aDate [

	^ self
		  shortNamed: anISO4217Code
		  singularNamed: aName
		  pluralNamed: aName
		  subUnitDenominator: 1
		  withISO4217CodeOptional: ( Optional containing: anISO4217Code )
		  issuedOn: aDate
]

{ #category : #'instance creation' }
Currency class >> shortNamed: shortName singularNamed: singularName pluralNamed: pluralName subUnitDenominator: anInteger issuedOn: aDate [

	^ self
		  shortNamed: shortName
		  singularNamed: singularName
		  pluralNamed: pluralName
		  subUnitDenominator: anInteger
		  withISO4217CodeOptional: Optional unused
		  issuedOn: aDate
]

{ #category : #'private - instance creation' }
Currency class >> shortNamed: shortName singularNamed: singularName pluralNamed: pluralName subUnitDenominator: anInteger withISO4217CodeOptional: anOptional issuedOn: aDate [

	AssertionCheckerBuilder new
		raising: InstanceCreationFailed;
		checking: [ :asserter | 
			asserter
				enforce: [ shortName size between: 3 and: 6 ]
				because: 'A currency short name must have between 3 and 6 letters';
				enforce: [ singularName notEmpty ] because: 'A currency can''t have an empty name';
				enforce: [ pluralName notEmpty ] because: 'A currency can''t have an empty name';
				enforce: [ anInteger strictlyPositive and: [ anInteger isInteger ] ]
				because: 'The sub-unit denominator must be a strictly positive integer';
				enforce: [ anOptional withContentDo: [ :isoCode | isoCode size = 3 ] ifUnused: [ true ] ]
				because: 'ISO 4217 code must have exactly three letters'
			];
		buildAndCheck.

	^ self new
		  initializeShortNamed: shortName
		  singularNamed: singularName
		  pluralNamed: pluralName
		  subUnitDenominator: anInteger
		  withISO4217CodeOptional: anOptional
		  issuedOn: aDate
]

{ #category : #'instance creation' }
Currency class >> singularNamed: singularName pluralNamed: pluralName subUnitDenominator: anInteger withISO4217Code: isoCode issuedOn: aDate [

	^ self
		  shortNamed: isoCode
		  singularNamed: singularName
		  pluralNamed: pluralName
		  subUnitDenominator: anInteger
		  withISO4217CodeOptional: ( Optional containing: isoCode )
		  issuedOn: aDate
]

{ #category : #testing }
Currency >> hasISO4217Code [

	^ self withISO4217CodeDo: [ true ] ifUndefined: [ false ]
]

{ #category : #initialization }
Currency >> initializeShortNamed: aSshortName singularNamed: aSingularName pluralNamed: aPluralName subUnitDenominator: anInteger withISO4217CodeOptional: anOptional issuedOn: aDate [

	shortName := aSshortName.
	singularName := aSingularName.
	pluralName := aPluralName.
	subUnitDenominator := anInteger.
	iso4217CodeOptional := anOptional.
	issueDate := aDate
]

{ #category : #accessing }
Currency >> issueDate [

	^ issueDate
]

{ #category : #accessing }
Currency >> pluralName [

	^ pluralName
]

{ #category : #printing }
Currency >> printOn: stream [

	stream
		nextPutAll: shortName;
		space;
		nextPut: $-;
		space;
		nextPutAll: singularName
]

{ #category : #accessing }
Currency >> shortName [

	^ shortName
]

{ #category : #accessing }
Currency >> singularName [

	^ singularName
]

{ #category : #accessing }
Currency >> subUnitDenominator [

	^ subUnitDenominator
]

{ #category : #updating }
Currency >> synchronizeWith: aCurrency [

	shortName := aCurrency shortName.
	singularName := aCurrency singularName.
	pluralName := aCurrency pluralName.
	issueDate := aCurrency issueDate.
	subUnitDenominator := aCurrency subUnitDenominator.
	iso4217CodeOptional := aCurrency
		                       withISO4217CodeDo: [ :isoCode | Optional containing: isoCode ]
		                       ifUndefined: [ Optional unused ]
]

{ #category : #accessing }
Currency >> withISO4217CodeDo: aBlock [

	^ iso4217CodeOptional withContentDo: aBlock
]

{ #category : #accessing }
Currency >> withISO4217CodeDo: aBlock ifUndefined: anUndefinedBlock [

	^ iso4217CodeOptional withContentDo: aBlock ifUnused: anUndefinedBlock
]
