Class {
	#name : #StatusAwareCurrency,
	#superclass : #Object,
	#instVars : [
		'currency',
		'isCirculating'
	],
	#category : #'Currency-System-Model'
}

{ #category : #'instance creation' }
StatusAwareCurrency class >> basedOn: aCurrency [
	
	^self basedOn: aCurrency circulating: true 
]

{ #category : #'private - instance creation' }
StatusAwareCurrency class >> basedOn: aCurrency circulating: aStatus [ 
	
	^self new initializeBasedOn: aCurrency circulating: aStatus 
]

{ #category : #'instance creation' }
StatusAwareCurrency class >> nonCirculatingBasedOn: aCurrency [
	
	^self basedOn: aCurrency circulating: false 
]

{ #category : #converting }
StatusAwareCurrency >> asNonCirculating [

	^ self class nonCirculatingBasedOn: currency
]

{ #category : #converting }
StatusAwareCurrency >> basedOn: aCurrency [

	^ self class basedOn: aCurrency circulating: isCirculating
]

{ #category : #private }
StatusAwareCurrency >> currency [

	^ currency
]

{ #category : #testing }
StatusAwareCurrency >> hasISO4217Code [

	^ currency hasISO4217Code
]

{ #category : #initialization }
StatusAwareCurrency >> initializeBasedOn: aCurrency circulating: aBoolean [

	currency := aCurrency.
	isCirculating := aBoolean
]

{ #category : #testing }
StatusAwareCurrency >> isCirculating [

	^ isCirculating
]

{ #category : #accessing }
StatusAwareCurrency >> issueDate [

	^ currency issueDate
]

{ #category : #accessing }
StatusAwareCurrency >> pluralName [

	^ currency pluralName
]

{ #category : #printing }
StatusAwareCurrency >> printOn: stream [

	currency printOn: stream
]

{ #category : #accessing }
StatusAwareCurrency >> shortName [

	^ currency shortName
]

{ #category : #accessing }
StatusAwareCurrency >> singularName [

	^ currency singularName
]

{ #category : #accessing }
StatusAwareCurrency >> subUnitDenominator [

	^ currency subUnitDenominator
]

{ #category : #updating }
StatusAwareCurrency >> synchronizeWith: aStatusAwareCurrency [

	isCirculating := aStatusAwareCurrency isCirculating.
	currency synchronizeWith: aStatusAwareCurrency currency
]

{ #category : #enumerating }
StatusAwareCurrency >> withISO4217CodeDo: aBlock [

	^ currency withISO4217CodeDo: aBlock
]

{ #category : #enumerating }
StatusAwareCurrency >> withISO4217CodeDo: aBlock ifUndefined: anUndefinedBlock [

	^ currency withISO4217CodeDo: aBlock ifUndefined: anUndefinedBlock
]
