Class {
	#name : #CreateEmptyCurrencyAPIRDBMSApplication,
	#superclass : #CreateEmptyRDBMSApplication,
	#category : #'Currency-API-Model'
}

{ #category : #accessing }
CreateEmptyCurrencyAPIRDBMSApplication class >> applicationBaselineName [

	^ #BaselineOfCurrencyAPI
]

{ #category : #initialization }
CreateEmptyCurrencyAPIRDBMSApplication class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : #accessing }
CreateEmptyCurrencyAPIRDBMSApplication class >> saganConfigurationParameters [

	^ self saganConfigurationParametersForPostgreSQL
]

{ #category : #'private - accessing' }
CreateEmptyCurrencyAPIRDBMSApplication >> installation [

	^ CurrencyAPIInstallation installedBy: self
]
