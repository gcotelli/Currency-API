Class {
	#name : #CurrencyAPIApplication,
	#superclass : #StargateApplication,
	#instVars : [
		'rootSystemOptional'
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
CurrencyAPIApplication class >> description [

	^ 'I provide a RESTful API over HTTP to manage currencies'
]

{ #category : #initialization }
CurrencyAPIApplication class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : #'private - activation/deactivation' }
CurrencyAPIApplication >> basicStartWithin: context [

	self installAndStartRootSystem.
	super basicStartWithin: context
]

{ #category : #'private - activation/deactivation' }
CurrencyAPIApplication >> basicStop [

	super basicStop.
	self withRootSystemDo: [ :system | 
		LaunchpadLogRecord emitInfo: 'Stopping system'.
		system shutDown
		]
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> controllersToInstall [

	| controllersToInstall |

	controllersToInstall := OrderedCollection new.
	self withRootSystemDo: [ :rootSystem | 
		controllersToInstall add: ( CurrencyRESTfulController workingWith: rootSystem ) ].
	^ controllersToInstall
]

{ #category : #initialization }
CurrencyAPIApplication >> initialize [

	super initialize.
	rootSystemOptional := Optional unused
]

{ #category : #'private - activation/deactivation' }
CurrencyAPIApplication >> installAndStartRootSystem [

	LaunchpadLogRecord emitInfo: 'Installing system'.
	rootSystemOptional := Optional containing: ( self installation install: self class version ).
	LaunchpadLogRecord emitInfo: 'Starting up system'.
	self withRootSystemDo: [ :system | system startUp ]
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> installation [

	^ CurrencyAPIInstallation new
]

{ #category : #enumerating }
CurrencyAPIApplication >> withRootSystemDo: aBlock [

	rootSystemOptional withContentDo: aBlock
]
