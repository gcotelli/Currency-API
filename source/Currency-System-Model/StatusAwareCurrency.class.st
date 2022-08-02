Class {
	#name : #StatusAwareCurrency,
	#superclass : #Object,
	#instVars : [
		'currency',
		'isCirculating',
		'uuid',
		'sequentialNumber'
	],
	#category : #'Currency-System-Model'
}

{ #category : #'private - instance creation' }
StatusAwareCurrency class >> basedOn: aCurrency circulating: aStatus identifiedBy: anUUID [

	^ self new initializeBasedOn: aCurrency circulating: aStatus identifiedBy: anUUID
]

{ #category : #'instance creation' }
StatusAwareCurrency class >> basedOn: aCurrency identifiedBy: anUUID [

	^ self basedOn: aCurrency circulating: true identifiedBy: anUUID
]

{ #category : #'instance creation' }
StatusAwareCurrency class >> nonCirculatingBasedOn: aCurrency identifiedBy: anUUID [

	^ self basedOn: aCurrency circulating: false identifiedBy: anUUID
]

{ #category : #converting }
StatusAwareCurrency >> asNonCirculating [

	^ self class nonCirculatingBasedOn: currency identifiedBy: self uuid
]

{ #category : #converting }
StatusAwareCurrency >> basedOn: aCurrency [

	^ self class basedOn: aCurrency circulating: isCirculating identifiedBy: uuid
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
StatusAwareCurrency >> initializeBasedOn: aCurrency circulating: aBoolean identifiedBy: anUUID [

	currency := aCurrency.
	isCirculating := aBoolean.
	uuid := anUUID 
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
StatusAwareCurrency >> sequentialNumber [

	^ sequentialNumber
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

{ #category : #accessing }
StatusAwareCurrency >> uuid [

	^ uuid
]

{ #category : #enumerating }
StatusAwareCurrency >> withISO4217CodeDo: aBlock [

	^ currency withISO4217CodeDo: aBlock
]

{ #category : #enumerating }
StatusAwareCurrency >> withISO4217CodeDo: aBlock ifUndefined: anUndefinedBlock [

	^ currency withISO4217CodeDo: aBlock ifUndefined: anUndefinedBlock
]
