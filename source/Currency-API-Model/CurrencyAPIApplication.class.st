Class {
	#name : #CurrencyAPIApplication,
	#superclass : #PersistentAPIApplication,
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
CurrencyAPIApplication class >> saganConfigurationParameters [

	^ CreateEmptyCurrencyAPIRDBMSApplication saganConfigurationParameters
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> controllersToInstall [

	^ { CurrencyRESTfulController workingWith: rootSystem }
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> installation [

	^ CurrencyAPIInstallation installedBy: self
]

{ #category : #'private - accessing' }
CurrencyAPIApplication >> serviceDefinitions [

	^ { self
		    buildServiceDefinitionNamed: 'currencies'
		    configuredBy: [ :builder | builder addTag: 'requires-backup' ] }
]
