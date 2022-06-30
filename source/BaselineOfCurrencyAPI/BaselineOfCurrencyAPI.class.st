Class {
	#name : #BaselineOfCurrencyAPI,
	#superclass : #BaselineOf,
	#category : #BaselineOfCurrencyAPI
}

{ #category : #baselines }
BaselineOfCurrencyAPI >> baseline: spec [

	<baseline>
	spec for: #pharo do: [ 
		self
			setUpDependencies: spec;
			setUpDeploymentPackages: spec;
			setUpTestPackages: spec.
		spec
			group: 'CI' with: 'Tests';
			group: 'Tools' with: 'Buoy-Tools';
			group: 'Development' with: #( 'Tests' 'Tools' )
		]
]

{ #category : #accessing }
BaselineOfCurrencyAPI >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : #baselines }
BaselineOfCurrencyAPI >> setUpDependencies: spec [

	spec
		baseline: 'Buoy' with: [ spec repository: 'github://ba-st/Buoy:v6' ];
		project: 'Buoy-Deployment' copyFrom: 'Buoy' with: [ spec loads: 'Deployment' ];
		project: 'Buoy-SUnit' copyFrom: 'Buoy' with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'Buoy-Tools' copyFrom: 'Buoy' with: [ spec loads: 'Tools' ].

	spec
		baseline: 'Chalten' with: [ spec repository: 'github://ba-st/Chalten:v8' ];
		project: 'Chalten-Deployment' copyFrom: 'Buoy' with: [ spec loads: 'Deployment' ]
]

{ #category : #baselines }
BaselineOfCurrencyAPI >> setUpDeploymentPackages: spec [

	spec
		package: 'Currency-Model' with: [ spec requires: 'Buoy-Deployment' ];
		group: 'Deployment' with: 'Currency-Model'
]

{ #category : #baselines }
BaselineOfCurrencyAPI >> setUpTestPackages: spec [

	spec
		package: 'Currency-Model-Tests'
		with: [ spec requires: #( 'Buoy-SUnit' 'Chalten-Deployment' 'Currency-Model' ) ];
		group: 'Tests' with: 'Currency-Model-Tests'
]
