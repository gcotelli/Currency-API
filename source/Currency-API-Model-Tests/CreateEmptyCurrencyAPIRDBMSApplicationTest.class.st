"
A CreateEmptyCurrencyAPIRDBMSApplicationTest is a test class for testing the behavior of CreateEmptyCurrencyAPIRDBMSApplication
"
Class {
	#name : #CreateEmptyCurrencyAPIRDBMSApplicationTest,
	#superclass : #TestCase,
	#instVars : [
		'logger'
	],
	#category : #'Currency-API-Model-Tests'
}

{ #category : #tests }
CreateEmptyCurrencyAPIRDBMSApplicationTest >> allPostgreSQLArguments [

	^ #( '--sagan.pg-hostname=localhost' '--sagan.pg-username=postgres' '--sagan.pg-password=secret'
	     '--sagan.pg-database-name=test' )	
]

{ #category : #running }
CreateEmptyCurrencyAPIRDBMSApplicationTest >> runCase [

	self shouldnt: [ super runCase ] raise: Exit
]

{ #category : #tests }
CreateEmptyCurrencyAPIRDBMSApplicationTest >> setUp [

	super setUp.
	logger := MemoryLogger new
]

{ #category : #private }
CreateEmptyCurrencyAPIRDBMSApplicationTest >> start: aLaunchpadApplication withAll: arguments [

	logger runDuring: [ 
		String streamContents: [ :stream | 
			| rootCommand commandLine context |

			rootCommand := LaunchpadRootCommand new.
			commandLine := CommandLineArguments withArguments: { 
					               'launchpad'.
					               'start'.
					               '--debug-mode'.
					               aLaunchpadApplication commandName } , arguments.
			context := LaunchpadCommandLineProcessingContext handling: commandLine writingTo: stream.
			self assert: ( rootCommand canHandle: ( context nextCommandLineArgumentIfNone: [ self fail ] ) ).
			rootCommand evaluateWithin: context
			]
		]
]

{ #category : #running }
CreateEmptyCurrencyAPIRDBMSApplicationTest >> tearDown [

	Beacon instance announcer subscriptions reset.
	super tearDown
]

{ #category : #tests }
CreateEmptyCurrencyAPIRDBMSApplicationTest >> testAccessing [

	self
		assert: CreateEmptyCurrencyAPIRDBMSApplication commandName equals: 'create-empty-rdbms';
		assert: CreateEmptyCurrencyAPIRDBMSApplication description
		equals: 'Creates the database structure';
		assert: CreateEmptyCurrencyAPIRDBMSApplication version notEmpty;
		assert: CreateEmptyCurrencyAPIRDBMSApplication applicationBaselineName
		equals: #BaselineOfCurrencyAPI
]

{ #category : #tests }
CreateEmptyCurrencyAPIRDBMSApplicationTest >> testActivationWithAllArguments [

	self
		shouldnt: [ 
		self start: CreateEmptyCurrencyAPIRDBMSApplication withAll: self allPostgreSQLArguments ]
		raise: Exit.

	logger recordings
		with:
			#( '[INFO] create-empty-rdbms'
				'[INFO] Obtaining configuration...'
				'[WARNING] "PG Port" parameter not provided. Using default.'
			   '[INFO] PG Hostname: localhost'
				'[INFO] PG Port: 5432'
				'[INFO] PG Username: postgres'
			   '[INFO] PG Password: **********'
				'[INFO] PG Database Name: test'
			   '[INFO] Obtaining configuration... [DONE]'
				'[INFO] Installing system'
			   '[INFO] Starting up system'
				'[INFO] Setting up database structure'
				'[INFO] Shutting down system'
				'[INFO] Exit application' )
		do: [ :record :expectedString | 
		self assert: ( record printString includesSubstring: expectedString ) ]
]
