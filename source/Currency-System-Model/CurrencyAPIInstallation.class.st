Class {
	#name : #CurrencyAPIInstallation,
	#superclass : #SystemInstallation,
	#category : #'Currency-System-Model'
}

{ #category : #installing }
CurrencyAPIInstallation >> beAwareOfShutDownOf: aCompositeSystem [ 


]

{ #category : #accessing }
CurrencyAPIInstallation >> modulesToInstall [

	^ { CurrencyManagementModule }
]

{ #category : #accessing }
CurrencyAPIInstallation >> name [

	^ 'Currency API'
]
