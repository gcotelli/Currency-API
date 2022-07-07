"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestCurrencyAPIModelTests,
	#superclass : #PackageManifest,
	#category : #'Currency-API-Model-Tests'
}

{ #category : #'code-critics' }
ManifestCurrencyAPIModelTests class >> ruleSentNotImplementedRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#'Currency-API-Model-Tests')) #'2022-07-07T09:10:28.770434-03:00') )
]

{ #category : #'code-critics' }
ManifestCurrencyAPIModelTests class >> ruleUncommonMessageSendRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#'Currency-API-Model-Tests')) #'2022-07-07T09:10:38.607616-03:00') )
]
