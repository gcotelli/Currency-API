Class {
	#name : #CurrencyManagementModule,
	#superclass : #SystemModule,
	#instVars : [
		'rootSystem'
	],
	#category : #'Currency-System-Model'
}

{ #category : #'instance creation' }
CurrencyManagementModule class >> toInstallOn: aCompositeSystem [

	^ self new initializeToInstallOn: aCompositeSystem
]

{ #category : #initialization }
CurrencyManagementModule >> initializeToInstallOn: aCompositeSystem [

	rootSystem := aCompositeSystem 
]

{ #category : #private }
CurrencyManagementModule >> name [

	^ 'Currency Management'
]

{ #category : #private }
CurrencyManagementModule >> registerCurrencyManagementSystemForInstallationIn: systems [

	^ self register: [ CurrencyManagementSystem new ] in: systems
]

{ #category : #private }
CurrencyManagementModule >> rootSystem [

	^ rootSystem
]

{ #category : #private }
CurrencyManagementModule >> systemInterfacesToInstall [

	^ #( CurrencyManagementSystem )
]
