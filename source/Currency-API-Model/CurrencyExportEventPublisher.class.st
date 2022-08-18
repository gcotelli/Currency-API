Class {
	#name : #CurrencyExportEventPublisher,
	#superclass : #RabbitMQClient,
	#instVars : [
		'configuration',
		'channel'
	],
	#category : #'Currency-API-Model'
}

{ #category : #'instance creation' }
CurrencyExportEventPublisher class >> configuredBy: configurationAction [

	| options |

	options := Dictionary new.
	configurationAction cull: options.
	^ self with: options
]

{ #category : #'instance creation' }
CurrencyExportEventPublisher class >> with: options [

	^ self new initializeWith: options
]

{ #category : #accessing }
CurrencyExportEventPublisher >> channel [

	channel ifNil: [ 
		channel := connection createChannel.
		channel queueDeclare: self queueName durable: true
		].
	^ channel
]

{ #category : #'private - configuring' }
CurrencyExportEventPublisher >> configureConnection: builder [

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

{ #category : #initialization }
CurrencyExportEventPublisher >> initializeWith: options [

	configuration := options.
	self initializeConnection
]

{ #category : #'private - configuring' }
CurrencyExportEventPublisher >> options [

	^ configuration
]

{ #category : #accessing }
CurrencyExportEventPublisher >> queueName [

	^ configuration at: #workerQueueName
]

{ #category : #publishing }
CurrencyExportEventPublisher >> requestDataExportBy: requestor identifiedWith: taskId [

	| json |

	json := NeoJSONWriter toString: ( OrderedDictionary new
			          at: #taskId put: taskId;
			          at: #requestor put: requestor;
			          yourself ).

	LaunchpadLogRecord emitDebuggingInfo:
		( 'Date export requested. Publishing <1s> to <2s>' expandMacrosWith: json with: self queueName ).
	self channel basicPublish: json utf8Encoded exchange: '' routingKey: self queueName
]

{ #category : #private }
CurrencyExportEventPublisher >> startProcessing [

	
]
