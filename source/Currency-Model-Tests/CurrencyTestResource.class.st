Class {
	#name : #CurrencyTestResource,
	#superclass : #TestResource,
	#instVars : [
		'usd',
		'yen'
	],
	#category : #'Currency-Model-Tests'
}

{ #category : #running }
CurrencyTestResource >> setUp [

	super setUp.
	usd := Currency
		       singularNamed: 'United States Dollar'
		       pluralNamed: 'United States Dollars'
		       subUnitDenominator: 100
		       withISO4217Code: 'USD'
		       issuedOn: ( April second , 1792 ) asSmalltalkDate.
	yen := Currency
		       named: 'Japanese Yen'
		       withISO4217Code: 'JPY'
		       issuedOn: ( June twentyseventh , 1871 ) asSmalltalkDate
]

{ #category : #accessing }
CurrencyTestResource >> usd [

	^ usd
]

{ #category : #accessing }
CurrencyTestResource >> yen [

	^ yen
]
