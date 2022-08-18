Class {
	#name : #CurrencyAPIApplication,
	#superclass : #PersistentAPIApplication,
	#instVars : [
		'publisher'
	],
	#category : #'Currency-API-Model'
}

{ #category : #private }
CurrencyAPIApplication class >> applicationBaselineName [

	^ #BaselineOfCurrencyAPI
]

{ #category : #accessing }
CurrencyAPIApplication class >> commandName [

	^ 'currency-api'
]

{ #category : #accessing }
CurrencyAPIApplication class >> configurationParameters [

	^ super configurationParameters , self rabbitMQConfigurationParameters
]

{ #category : #private }
CurrencyAPIApplication class >> defaultMaxActiveSessionsCount [

	^ 5
]

{ #category : #private }
CurrencyAPIApplication class >> defaultMaxIdleSessionsCount [

	^ 5
]

{ #category : #private }
CurrencyAPIApplication class >> defaultMinIdleSessionsCount [

	^ 2
]

{ #category : #accessing }
CurrencyAPIApplication class >> description [

	^ 'I provide a RESTful API over HTTP to manage currencies'
]

{ #category : #initialization }
CurrencyAPIApplication class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : #accessing }
CurrencyAPIApplication class >> rabbitMQConfigurationParameters [

	^ Array
		  with:
		  ( MandatoryConfigurationParameter named: 'Worker Queue Name' describedBy: 'Rabbit MQ queue name' )
		  with: ( MandatoryConfigurationParameter
				    named: 'Username'
				    describedBy: 'Rabbit MQ username'
				    inside: #( 'RabbitMQ' ) )
		  with: ( MandatoryConfigurationParameter
				    named: 'Password'
				    describedBy: 'Rabbit MQ password'
				    inside: #( 'RabbitMQ' ) ) asSensitive
		  with: ( MandatoryConfigurationParameter
				    named: 'Hostname'
				    describedBy: 'Rabbit MQ hostname'
				    inside: #( 'RabbitMQ' ) )
		  with: ( OptionalConfigurationParameter
				    named: 'Time Slot between retries in ms'
				    describedBy: 'Milliseconds to wait before retrying a connection to RabbitMQ'
				    inside: #( 'RabbitMQ' )
				    defaultingTo: 100
				    convertingWith: #asNumber )
]

{ #category : #accessing }
CurrencyAPIApplication class >> saganConfigurationParameters [

	^ CreateEmptyCurrencyAPIRDBMSApplication saganConfigurationParameters
]

{ #category : #'private - activation/deactivation' }
CurrencyAPIApplication >> basicStop [

	LaunchpadLogRecord emitInfo: 'Stopping publisher' during: [ publisher ifNotNil: #stop ].
	super basicStop
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> controllersToInstall [

	^ { 
		  CurrencyRESTfulController workingWith: rootSystem.
		  self currencyExportJRPCController }
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> currencyExportJRPCController [

	^ JsonRPCController configuredBy: [ :options | 
		  options
			  at: #endpoint put: 'currency-export';
			  at: #procedureDefinitions put: { self requestDataExportDefinition }
		  ]
]

{ #category : #'private - activation/deactivation' }
CurrencyAPIApplication >> installAndStartRootSystem [

	super installAndStartRootSystem.
	LaunchpadLogRecord emitInfo: 'Starting publisher' during: [ 
		publisher := CurrencyExportEventPublisher configuredBy: [ :options | 
			             options
				             at: #workerQueueName put: self configuration workerQueueName;
				             at: #rabbitMQUsername put: self rabbitMQConfiguration username;
				             at: #rabbitMQPassword put: self rabbitMQConfiguration password;
				             at: #rabbitMQHostname put: self rabbitMQConfiguration hostname;
				             at: #retry
				             put: [ :retry | 
					             retry backoffExponentiallyWithTimeSlot:
							             self rabbitMQTimeSlotBetweenConnectionRetries ]
			             ].
		publisher start
		]
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> installation [

	^ CurrencyAPIInstallation installedBy: self
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> rabbitMQConfiguration [

	^self configuration rabbitmq
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> rabbitMQTimeSlotBetweenConnectionRetries [

	^ self rabbitMQConfiguration timeSlotBetweenRetriesInMs milliSeconds
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> requestDataExportDefinition [

	^ [ :requestHandler | 
	  requestHandler
		  addHandlerNamed: 'export'
		  withArgumentNames: #( requestor )
		  evaluating: [ :requestor | 
			  | taskId |
			  taskId := UUID new printString.
			  publisher requestDataExportBy: requestor identifiedWith: taskId.
			  { #taskId -> taskId } asOrderedDictionary
			  ]
	  ]
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> serviceDefinitions [

	^ { self
		    buildServiceDefinitionNamed: 'currencies'
		    configuredBy: [ :builder | builder addTag: 'requires-backup' ] }
]
