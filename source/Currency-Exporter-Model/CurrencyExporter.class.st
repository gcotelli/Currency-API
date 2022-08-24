Class {
	#name : #CurrencyExporter,
	#superclass : #LaunchpadApplication,
	#instVars : [
		'workerOptional',
		'serverOptional'
	],
	#classInstVars : [
		'Version'
	],
	#category : #'Currency-Exporter-Model'
}

{ #category : #accessing }
CurrencyExporter class >> commandName [

	^ 'currency-exporter'
]

{ #category : #private }
CurrencyExporter class >> configurationParameters [

	^ CreateEmptyRDBMSApplication saganConfigurationParametersForPostgreSQL
	  , self rabbitMQConfigurationParameters
]

{ #category : #accessing }
CurrencyExporter class >> description [ 

	^ 'A worker processing events from a RabbitMQ queue to export currency data in an asynchronous way'
]

{ #category : #private }
CurrencyExporter class >> fileReferenceToDumpStackTrace [

	^ self logsDirectory / ( '<1s>-<2s>.fuel'
		    expandMacrosWith: self commandName
		    with: ( ( ZTimestampFormat fromString: '2001-02-03_16-05-06.07' ) format: ZTimestamp now ) )
]

{ #category : #private }
CurrencyExporter class >> initialize [

	<ignoreForCoverage>
	Version := VersionFromRepositoryResolver new valueFor: #BaselineOfCurrencyAPI
]

{ #category : #private }
CurrencyExporter class >> logsDirectory [

	^ FileLocator workingDirectory / 'logs'
]

{ #category : #private }
CurrencyExporter class >> rabbitMQConfigurationParameters [

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

{ #category : #private }
CurrencyExporter class >> version [

	^ Version
]

{ #category : #'private - activation/deactivation' }
CurrencyExporter >> basicStartWithin: context [

	| rootSystem |

	LaunchpadLogRecord emitInfo: 'Installing system'.
	rootSystem := ( CurrencyAPIInstallation installedBy: self ) install: self class version.
	LaunchpadLogRecord emitInfo: 'Starting up system'.
	rootSystem startUp.
	self initializeWebServer.
	LaunchpadLogRecord emitInfo: 'Starting web server'.
	self serverDo: [ :server | server start ].
	self initializeWorkerWorkingOn: rootSystem.
	LaunchpadLogRecord emitInfo: 'Starting up worker'.
	self workerDo: [ :worker | worker start ]
]

{ #category : #'private - activation/deactivation' }
CurrencyExporter >> basicStop [

	self workerDo: [ :worker | worker stop ].
	self serverDo: [ :server | server stop ].
	super basicStop
]

{ #category : #initialization }
CurrencyExporter >> initialize [

	super initialize.
	workerOptional := Optional unused.
	serverOptional := Optional unused
]

{ #category : #initialization }
CurrencyExporter >> initializeWebServer [

	| server delegate |

	server := ZnServer on: 8081.
	delegate := ZnStaticFileServerDelegate new
		            directory: FileLocator workingDirectory / 'data';
		            prefixFromString: 'export-data';
		            yourself.
	server delegate: delegate.
	serverOptional := Optional containing: server
]

{ #category : #initialization }
CurrencyExporter >> initializeWorkerWorkingOn: rootSystem [

	| worker |

	worker := CurrencyExportWorker workingOn: rootSystem configuredBy: [ :options | 
		          options
			          at: #workerQueueName put: self configuration workerQueueName;
			          at: #rabbitMQUsername put: self rabbitMQConfiguration username;
			          at: #rabbitMQPassword put: self rabbitMQConfiguration password;
			          at: #rabbitMQHostname put: self rabbitMQConfiguration hostname;
			          at: #retry
			          put: [ :retry | 
				          retry backoffExponentiallyWithTimeSlot: self rabbitMQTimeSlotBetweenConnectionRetries ]
		          ].

	workerOptional := Optional containing: worker
]

{ #category : #'private - accessing' }
CurrencyExporter >> rabbitMQConfiguration [

	^ self configuration rabbitmq
]

{ #category : #'private - accessing' }
CurrencyExporter >> rabbitMQTimeSlotBetweenConnectionRetries [

	^ self rabbitMQConfiguration timeSlotBetweenRetriesInMs milliSeconds
]

{ #category : #'private - accessing' }
CurrencyExporter >> saganConfiguration [

	^ self configuration sagan
]

{ #category : #enumerating }
CurrencyExporter >> serverDo: aBlock [

	serverOptional withContentDo: aBlock
]

{ #category : #'error handling' }
CurrencyExporter >> stackTraceDumper [

	^ StackTraceBinarySerializer on: [ :dumpAction | 
		  self class fileReferenceToDumpStackTrace binaryWriteStreamDo: dumpAction ]
]

{ #category : #enumerating }
CurrencyExporter >> workerDo: aBlock [

	workerOptional withContentDo: aBlock
]
