"
A CurrencyExportWorkerTest is a test class for testing the behavior of CurrencyExportWorker
"
Class {
	#name : #CurrencyExportWorkerTest,
	#superclass : #SystemBasedUserStoryTest,
	#instVars : [
		'logger',
		'worker'
	],
	#category : #'Currency-Exporter-Model-Tests'
}

{ #category : #accessing }
CurrencyExportWorkerTest class >> resources [

	^ { CurrencyTestResource }
]

{ #category : #running }
CurrencyExportWorkerTest >> setUp [

	super setUp.
	logger := MemoryLogger new.
	worker := CurrencyExportWorker workingOn: rootSystem configuredBy: [ :options |  ]
]

{ #category : #running }
CurrencyExportWorkerTest >> setUpRequirements [

	| repositorySystem |

	repositorySystem := RepositoryProviderSystem new.
	repositorySystem register: InMemoryRepositoryProvider new as: #mainDB.
	self registerSubsystem: repositorySystem.
	self requireInstallationOf: CurrencyManagementModule
]

{ #category : #tests }
CurrencyExportWorkerTest >> testEncodeAllCurrenciesOn [

	| export |

	export := String streamContents: [ :stream | 
		          logger runDuring: [ worker encodeAllCurrenciesOn: stream ] ].

	self
		assert: export equals: '[]';
		assert: logger recordings isEmpty
]

{ #category : #tests }
CurrencyExportWorkerTest >> testEncodeAllCurrenciesOnWhenNotEmpty [

	| export |

	( rootSystem >> #CurrencyManagementSystem )
		storeCurrency: CurrencyTestResource current usd;
		storeCurrency: CurrencyTestResource current yen.

	export := String streamContents: [ :stream | 
		          logger runDuring: [ worker encodeAllCurrenciesOn: stream ] ].

	self
		assert: export equals: '[{"shortName":"JPY","singularName":"Japanese Yen","pluralName":"Japanese Yen","ISO4217Code":"JPY","issueDate":"1871-06-27","subUnitDenominator":1},{"shortName":"USD","singularName":"United States Dollar","pluralName":"United States Dollars","ISO4217Code":"USD","issueDate":"1792-04-02","subUnitDenominator":100}]';
		assert: logger recordings isEmpty
]

{ #category : #tests }
CurrencyExportWorkerTest >> testProcess [

	| taskId payload expectedOutputFile |

	taskId := UUID new printString.

	expectedOutputFile := FileLocator workingDirectory / 'data'
	                      / ( '<1s>.json' expandMacrosWith: taskId ).

	self deny: expectedOutputFile exists.

	payload := NeoJSONWriter toString: ( OrderedDictionary new
			             at: #taskId put: taskId;
			             at: #requestor put: 'user@example.com';
			             yourself ).

	logger runDuring: [ worker process: payload utf8Encoded ].

	self
		assert: expectedOutputFile exists;
		assert: expectedOutputFile contents equals: '[]';
		withTheOnlyOneIn: logger recordings do: [ :recording | 
			self assert: ( recording printString endsWith:
							  ( '[DEBUG] Task received {"task":"{\"taskId\":\"<1s>\",\"requestor\":\"user@example.com\"}"}' 
								    expandMacrosWith: taskId ) )
			].

	expectedOutputFile ensureDelete
]

{ #category : #tests }
CurrencyExportWorkerTest >> testProcessInvalidPayload [

	logger runDuring: [ worker process: '' utf8Encoded ].

	logger recordings
		with: #( '[DEBUG] Task received {"task":""}'
					'[ERROR] Invalid payload: invalid input: nil' )
		do: [ :recording :expected | self assert: ( recording printString endsWith: expected ) ]
]

{ #category : #tests }
CurrencyExportWorkerTest >> testProcessPayloadMissingTaskId [

	logger runDuring: [ worker process: '{"requestor":"user@example.com"}' utf8Encoded ].

	logger recordings
		with: #( '[DEBUG] Task received {"task":"{\"requestor\":\"user@example.com\"}"}'
			   		'[ERROR] Missing #taskId field.' )
		do: [ :recording :expected | self assert: ( recording printString endsWith: expected ) ]
]
