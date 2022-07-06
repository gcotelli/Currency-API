Extension { #name : #Currency }

{ #category : #'*Currency-API-Model' }
Currency class >> basedOn: json [

	| iso4217CodeOptional shortName singularName pluralName subUnitDenominator issueDate |

	iso4217CodeOptional := json
		                       at: #ISO4217Code
		                       ifPresent: [ :code | 
			                       shortName := code.
			                       Optional containing: code
			                       ]
		                       ifAbsent: [ Optional unused ].

	json
		at: #shortName
		ifPresent: [ :string | shortName := string ]
		ifAbsent: [ shortName ifNil: [ HTTPClientError badRequest signal: 'Missing #shortName field.' ] ].
	json
		at: #singularName
		ifPresent: [ :string | singularName := pluralName := string ]
		ifAbsent: [ HTTPClientError badRequest signal: 'Missing #singularName field.' ].
	json
		at: #pluralName
		ifPresent: [ :string | pluralName := string ]
		ifAbsent: [ pluralName ifNil: [ HTTPClientError badRequest signal: 'Missing #pluralName field.' ] ].
	subUnitDenominator := json at: #subUnitDenominator ifPresent: [ :number | number ] ifAbsent: [ 1 ].
	json
		at: #issueDate
		ifPresent: [ :string | issueDate := Date readFrom: string pattern: 'yyyy-mm-dd' ]
		ifAbsent: [ HTTPClientError badRequest signal: 'Missing #issueDate field.' ].

	^ self
		  shortNamed: shortName
		  singularNamed: singularName
		  pluralNamed: pluralName
		  subUnitDenominator: subUnitDenominator
		  withISO4217CodeOptional: iso4217CodeOptional
		  issuedOn: issueDate
]
