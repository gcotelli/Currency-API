Class {
	#name : #CurrencyExportWorker,
	#superclass : #RabbitMQWorker,
	#instVars : [
		'configuration',
		'workingContext'
	],
	#category : #'Currency-Exporter-Model'
}

{ #category : #'instance creation' }
CurrencyExportWorker class >> workingOn: aContext configuredBy: configurationAction [

	| options |

	options := Dictionary new.
	configurationAction cull: options.
	^ self workingOn: aContext with: options
]

{ #category : #'instance creation' }
CurrencyExportWorker class >> workingOn: aContext with: options [

	^ self new initializeWorkingOn: aContext with: options
]

{ #category : #'private - configuring' }
CurrencyExportWorker >> configureConnection: builder [

	configuration
		at: #rabbitMQUsername
		ifPresent: [ :username | builder username: username ]
		ifAbsent: [ 
		LaunchpadLogRecord emitWarning: 'Missing RabbitMQ username configuration, using default.' ].
	configuration
		at: #rabbitMQPassword
		ifPresent: [ :password | builder password: password ]
		ifAbsent: [ 
		LaunchpadLogRecord emitWarning: 'Missing RabbitMQ password configuration, using default.' ].
	configuration
		at: #rabbitMQHostname
		ifPresent: [ :hostname | builder hostname: hostname ]
		ifAbsent: [ 
		LaunchpadLogRecord emitWarning: 'Missing RabbitMQ hostname configuration, using default.' ]
]

{ #category : #private }
CurrencyExportWorker >> encodeAllCurrenciesOn: stream [

	| writer |

	writer := NeoJSONWriter on: stream.
	writer
		for: #Currency do: [ :mapping | 
			mapping
				mapProperty: #shortName getter: #shortName;
				mapProperty: #singularName getter: #singularName;
				mapProperty: #pluralName getter: #pluralName;
				mapProperty: #ISO4217Code
				getter: [ :currency | currency withISO4217CodeDo: [ :code | code ] ifUndefined: [ nil ] ];
				mapProperty: #issueDate getter: #issueDate;
				mapProperty: #subUnitDenominator getter: #subUnitDenominator
			];
		for: Date customDo: [ :mapping | mapping encoder: [ :date | date yyyymmdd ] ];
		for: #CurrencyCollection customDo: [ :mapping | mapping listOfElementSchema: #Currency ].
	writer
		nextPut: ( workingContext >> #CurrencyManagementSystem ) allCurrencies
		as: #CurrencyCollection
]

{ #category : #initialization }
CurrencyExportWorker >> initializeWorkingOn: aContext with: options [

	workingContext := aContext.
	configuration := options.
	self initializeConnection
]

{ #category : #private }
CurrencyExportWorker >> logAsReceivedTask: decodedPayload [

	LaunchpadLogRecord
		emitStructuredDebuggingInfo: 'Task received'
		with: [ :data | data at: #task put: decodedPayload ]
]

{ #category : #private }
CurrencyExportWorker >> process: payload [

	self withEventIn: payload do: [ :event | 
		| fileReference |

		fileReference := FileLocator workingDirectory / 'data' / event taskId withExtension: 'json'.
		fileReference ensureCreateFile.
		fileReference writeStreamDo: [ :stream | self encodeAllCurrenciesOn: stream ]
		]
]

{ #category : #accessing }
CurrencyExportWorker >> queueName [

	^ configuration at: #workerQueueName
]

{ #category : #private }
CurrencyExportWorker >> withEventIn: payload do: aBlock [

	| decodedPayload event |

	decodedPayload := payload utf8Decoded.
	self logAsReceivedTask: decodedPayload.

	event := [ NeoJSONObject fromString: decodedPayload ]
		         on: NeoJSONParseError
		         do: [ :error | 
			         LaunchpadLogRecord emitError:
				         ( 'Invalid payload: <1s>' expandMacrosWith: error messageText ).
			         ^ self
			         ].
	event
		at: #taskId
		ifPresent: [ aBlock value: event ]
		ifAbsent: [ LaunchpadLogRecord emitError: 'Missing #taskId field.' ]
]
