"
A CurrencyExporterTest is a test class for testing the behavior of CurrencyExporter
"
Class {
	#name : #CurrencyExporterTest,
	#superclass : #TestCase,
	#instVars : [
		'logger',
		'application'
	],
	#category : #'Currency-Exporter-Model-Tests'
}

{ #category : #private }
CurrencyExporterTest >> allPostgreSQLArguments [

	^ #( '--sagan.pg-hostname=localhost' '--sagan.pg-username=postgres' '--sagan.pg-password=secret'
	     '--sagan.pg-database-name=test' )
]

{ #category : #private }
CurrencyExporterTest >> basicArguments [

	^ #( '--worker-queue-name=worker' )
]

{ #category : #private }
CurrencyExporterTest >> rabbitMQArguments [

	^ #( '--rabbitmq.username=guest' '--rabbitmq.password=guest' '--rabbitmq.hostname=localhost' )
]

{ #category : #running }
CurrencyExporterTest >> runCase [

	self shouldnt: [ super runCase ] raise: Exit
]

{ #category : #running }
CurrencyExporterTest >> setUp [

	super setUp.
	logger := MemoryLogger new.
	CurrencyExporter logsDirectory ensureCreateDirectory
]

{ #category : #running }
CurrencyExporterTest >> start: aLaunchpadApplication withAll: arguments [

	logger runDuring: [ 
		String streamContents: [ :stream | 
			| context rootCommand |

			rootCommand := LaunchpadRootCommand new.
			context := LaunchpadCommandLineProcessingContext
				           handling: ( CommandLineArguments withArguments: { 
							             'launchpad'.
							             'start'.
							             '--debug-mode'.
							             aLaunchpadApplication commandName } , arguments )
				           writingTo: stream.
			self assert: ( rootCommand canHandle: ( context nextCommandLineArgumentIfNone: [ self fail ] ) ).
			rootCommand evaluateWithin: context
			]
		]
]

{ #category : #running }
CurrencyExporterTest >> tearDown [

	application ifNotNil: #stop.
	super tearDown
]

{ #category : #tests }
CurrencyExporterTest >> testAccessing [

	self
		assert: CurrencyExporter commandName equals: 'currency-exporter';
		assert: CurrencyExporter description
		equals:
			'A worker processing events from a RabbitMQ queue to export currency data in an asynchronous way'
]

{ #category : #private }
CurrencyExporterTest >> testActivationWithAllArguments [

	[ 
	self
		shouldnt: [ 
			self
				start: CurrencyExporter
				withAll: self basicArguments , self allPostgreSQLArguments , self rabbitMQArguments
			]
		raise: Exit
	] forkNamed: 'Application startup'.

	Processor yield.

	application := LaunchpadApplication currentlyRunning.
	self
		assert: application configuration sagan pgUsername equals: 'postgres';
		assert: application configuration sagan pgHostname equals: 'localhost';
		assert: application configuration sagan pgPassword equals: 'secret';
		assert: application configuration sagan pgDatabaseName equals: 'test';
		assert: application configuration sagan pgPort equals: 5432;
		assert: application configuration rabbitmq hostname equals: 'localhost';
		assert: application configuration rabbitmq username equals: 'guest';
		assert: application configuration rabbitmq password equals: 'guest'
]
