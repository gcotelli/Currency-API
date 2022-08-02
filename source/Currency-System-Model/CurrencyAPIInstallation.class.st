Class {
	#name : #CurrencyAPIInstallation,
	#superclass : #SystemInstallation,
	#instVars : [
		'application'
	],
	#category : #'Currency-System-Model'
}

{ #category : #'instance creation' }
CurrencyAPIInstallation class >> installedBy: anApplication [

	^ self new initializeInstalledBy: anApplication
]

{ #category : #installing }
CurrencyAPIInstallation >> beAwareOfShutDownOf: aCompositeSystem [ 


]

{ #category : #initialization }
CurrencyAPIInstallation >> initializeInstalledBy: anApplication [

	application := anApplication
]

{ #category : #accessing }
CurrencyAPIInstallation >> modulesToInstall [

	^ { 
		  ( SinglePostgreSQLDatabaseProviderModuleFactory
			    configuredBy: application saganConfiguration
			    withPoolingOptions: [ :options |  ] ).
		  CurrencyManagementModule }
]

{ #category : #accessing }
CurrencyAPIInstallation >> name [

	^ 'Currency API'
]
