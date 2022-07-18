"
A CurrencyAPIInstallationTest is a test class for testing the behavior of CurrencyAPIInstallation
"
Class {
	#name : #CurrencyAPIInstallationTest,
	#superclass : #TestCase,
	#category : #'Currency-System-Model-Tests'
}

{ #category : #tests }
CurrencyAPIInstallationTest >> testAccessing [

	self assert: CurrencyAPIInstallation new name equals: 'Currency API'
]
