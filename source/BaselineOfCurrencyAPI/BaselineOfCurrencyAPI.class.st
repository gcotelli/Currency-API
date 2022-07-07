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
			group: 'Tools' with: #( 'Buoy-Tools' 'Stargate-Tools' );
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
		project: 'Chalten-Deployment'
		copyFrom: 'Chalten'
		with: [ spec loads: 'Chalten-Gregorian-Calendar' ].

	spec
		baseline: 'Kepler' with: [ spec repository: 'github://ba-st/Kepler:v5' ];
		project: 'Kepler-Deployment' copyFrom: 'Kepler' with: [ spec loads: 'Core' ];
		project: 'Kepler-SUnit' copyFrom: 'Kepler' with: [ spec loads: 'Dependent-SUnit-Extensions' ].

	spec
		baseline: 'Sagan' with: [ spec repository: 'github://ba-st/Sagan:v6' ];
		project: 'Sagan-Deployment' copyFrom: 'Sagan' with: [ spec loads: 'Core' ].

	spec
		baseline: 'Stargate' with: [ spec repository: 'github://ba-st/Stargate:v8' ];
		project: 'Stargate-Deployment' copyFrom: 'Stargate' with: [ spec loads: 'Deployment' ];
		project: 'Stargate-SUnit' copyFrom: 'Stargate' with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'Stargate-Tools' copyFrom: 'Stargate' with: [ spec loads: 'Tools' ]
]

{ #category : #baselines }
BaselineOfCurrencyAPI >> setUpDeploymentPackages: spec [

	spec
		package: 'Currency-Model' with: [ spec requires: 'Buoy-Deployment' ];
		group: 'Deployment' with: 'Currency-Model'.

	spec
		package: 'Currency-System-Model'
		with: [ spec requires: #( 'Kepler-Deployment' 'Sagan-Deployment' ) ];
		group: 'Deployment' with: 'Currency-System-Model'.

	spec
		package: 'Currency-API-Model'
		with: [ spec requires: #( 'Stargate-Deployment' 'Currency-System-Model' ) ];
		group: 'Deployment' with: 'Currency-API-Model'
]

{ #category : #baselines }
BaselineOfCurrencyAPI >> setUpTestPackages: spec [

	spec
		package: 'Currency-Model-Tests'
		with: [ spec requires: #( 'Buoy-SUnit' 'Chalten-Deployment' 'Currency-Model' ) ];
		group: 'Tests' with: 'Currency-Model-Tests'.

	spec
		package: 'Currency-System-Model-Tests'
		with: [ spec requires: #( 'Currency-System-Model' 'Currency-Model-Tests' 'Kepler-SUnit' ) ];
		group: 'Tests' with: 'Currency-System-Model-Tests'.

	spec
		package: 'Currency-API-Model-Tests'
		with: [ spec requires: #( 'Stargate-SUnit' 'Kepler-SUnit' 'Currency-API-Model' ) ];
		group: 'Tests' with: 'Currency-API-Model-Tests'
]
