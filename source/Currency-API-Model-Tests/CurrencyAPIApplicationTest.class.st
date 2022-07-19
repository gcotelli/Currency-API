"
A CurrencyAPIApplicationTest is a test class for testing the behavior of CurrencyAPIApplication
"
Class {
	#name : #CurrencyAPIApplicationTest,
	#superclass : #TestCase,
	#instVars : [
		'application',
		'port',
		'logger'
	],
	#category : #'Currency-API-Model-Tests'
}

{ #category : #private }
CurrencyAPIApplicationTest >> basicArguments [

	^ { 
		  '--stargate.public-url='.
		  '--stargate.port=<1p>' expandMacrosWith: port.
		  '--stargate.operations-secret=XXX' }
]

{ #category : #running }
CurrencyAPIApplicationTest >> runCase [

	self shouldnt: [ super runCase ] raise: Exit
]

{ #category : #running }
CurrencyAPIApplicationTest >> setUp [

	super setUp.
	port := self freeListeningTCPPort.
	logger := MemoryLogger new
]

{ #category : #private }
CurrencyAPIApplicationTest >> start: aLaunchpadApplication withAll: arguments [

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
			rootCommand evaluateWithin: context.
			application := LaunchpadApplication currentlyRunning
			]
		]
]

{ #category : #running }
CurrencyAPIApplicationTest >> tearDown [

	Beacon instance announcer subscriptions reset.
	application ifNotNil: #stop.
	super tearDown
]

{ #category : #tests }
CurrencyAPIApplicationTest >> testAccessing [

	self
		assert: CurrencyAPIApplication commandName equals: 'currency-api';
		assert: CurrencyAPIApplication description
		equals: 'I provide a RESTful API over HTTP to manage currencies';
		assert: CurrencyAPIApplication version notEmpty;
		assert: CurrencyAPIApplication applicationBaselineName equals: #BaselineOfCurrencyAPI
]

{ #category : #private }
CurrencyAPIApplicationTest >> testActivationMissingOperationsSecret [

	self
		should: [ 
			self start: CurrencyAPIApplication withAll: { 
					'--stargate.public-url='.
					'--stargate.port=<1p>' expandMacrosWith: port }
			]
		raise: RequiredConfigurationNotFound
		withMessageText: '"Operations Secret" parameter not present.'
]

{ #category : #private }
CurrencyAPIApplicationTest >> testActivationMissingPort [

	self
		should: [ 
			self
				start: CurrencyAPIApplication
				withAll: #( '--stargate.public-url=' '--stargate.operations-secret=XXX' )
			]
		raise: RequiredConfigurationNotFound
		withMessageText: '"Port" parameter not present.'
]

{ #category : #private }
CurrencyAPIApplicationTest >> testActivationMissingPublicURL [

	self
		should: [ 
			self start: CurrencyAPIApplication withAll: { 
					( '--stargate.port=<1p>' expandMacrosWith: port ).
					'--stargate.operations-secret=XXX' }
			]
		raise: RequiredConfigurationNotFound
		withMessageText: '"Public URL" parameter not present.'
]

{ #category : #private }
CurrencyAPIApplicationTest >> testActivationWithAllArguments [

	self shouldnt: [ self start: CurrencyAPIApplication withAll: self basicArguments ] raise: Exit.

	self
		assert: application configuration stargate publicURL isEmpty;
		assert: application configuration stargate port equals: port.

	logger recordings
		with: #( 
				'[INFO] currency-api'
				'[INFO] Obtaining configuration...'
			   '[INFO] Public URL: /'
				'[INFO] Port:'
				'[INFO] Operations Secret: **********'
			   '[INFO] Obtaining configuration... [DONE]'
				'[INFO] Installing system'
			   '[INFO] Starting up system'
				'[INFO] API Version:'
				'[INFO] Creating API...'
			   '[INFO] Creating API... [DONE]'
				'[INFO] Installing API...'
				'[INFO] Installing API... [DONE]'
			   '[INFO] Starting API...'
				'[INFO] Starting API... [DONE]' )
		do: [ :record :expectedString | 
		self assert: ( record printString includesSubstring: expectedString ) ]
]
