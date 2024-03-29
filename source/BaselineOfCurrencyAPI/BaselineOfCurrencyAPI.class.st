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
			group: 'Tools' with: #( 'Buoy-Tools' 'PersistentAPISkeleton-Tools' );
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
		baseline: 'PersistentAPISkeleton'
			with: [ spec repository: 'github://mercap/Persistent-API-Skeleton:release-candidate' ];
		project: 'PersistentAPISkeleton-PostgreSQL'
			copyFrom: 'PersistentAPISkeleton'
			with: [ spec loads: 'PostgreSQL Persistence' ];
		project: 'PersistentAPISkeleton-SUnit'
			copyFrom: 'PersistentAPISkeleton'
			with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'PersistentAPISkeleton-Tools'
			copyFrom: 'PersistentAPISkeleton'
			with: [ spec loads: 'Tools' ]
]

{ #category : #baselines }
BaselineOfCurrencyAPI >> setUpDeploymentPackages: spec [

	spec
		package: 'Currency-Model' with: [ spec requires: 'Buoy-Deployment' ];
		group: 'Deployment' with: 'Currency-Model'.

	spec
		package: 'Currency-System-Model'
		with: [ spec requires: #( 'PersistentAPISkeleton-PostgreSQL' 'Currency-Model' ) ];
		group: 'Deployment' with: 'Currency-System-Model'.

	spec
		package: 'Currency-API-Model' with: [ spec requires: 'Currency-System-Model' ];
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
		with: [ 
			spec requires: #( 'Currency-System-Model' 'Currency-Model-Tests' 'PersistentAPISkeleton-SUnit' ) ];
		group: 'Tests' with: 'Currency-System-Model-Tests'.

	spec
		package: 'Currency-API-Model-Tests'
		with: [ spec requires: #( 'PersistentAPISkeleton-SUnit' 'Currency-API-Model' ) ];
		group: 'Tests' with: 'Currency-API-Model-Tests'
]
