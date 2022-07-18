"
A CurrencyManagementModuleTest is a test class for testing the behavior of CurrencyManagementModule
"
Class {
	#name : #CurrencyManagementModuleTest,
	#superclass : #TestCase,
	#category : #'Currency-System-Model-Tests'
}

{ #category : #tests }
CurrencyManagementModuleTest >> testAccessing [

	| module |

	module := CurrencyManagementModule toInstallOn: CompositeSystem new.
	self
		assert: module name equals: 'Currency Management';
		assert: module systemInterfacesToInstall equals: #( CurrencyManagementSystem )
]
