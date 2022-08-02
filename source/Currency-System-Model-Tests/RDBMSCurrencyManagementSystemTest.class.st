Class {
	#name : #RDBMSCurrencyManagementSystemTest,
	#superclass : #CurrencyManagementSystemTest,
	#category : #'Currency-System-Model-Tests'
}

{ #category : #running }
RDBMSCurrencyManagementSystemTest >> configuration [

	^ NeoJSONObject new
		  at: #pgHostname put: 'localhost';
		  at: #pgPort put: 5432;
		  at: #pgUsername put: 'postgres';
		  at: #pgPassword put: 'secret';
		  at: #pgDatabaseName put: 'test';
		  yourself
]

{ #category : #running }
RDBMSCurrencyManagementSystemTest >> repositoryProvider [

	| login |

	login := ( SinglePostgreSQLDatabaseProviderModuleFactory configuredBy: self configuration )
		         databaseLogin.

	^ RDBMSRepositoryProvider using: login		
]

{ #category : #running }
RDBMSCurrencyManagementSystemTest >> setUp [

	super setUp.
	( rootSystem >> #RepositoryProviderSystem ) prepareForInitialPersistence
]

{ #category : #running }
RDBMSCurrencyManagementSystemTest >> tearDown [

	( rootSystem >> #RepositoryProviderSystem ) destroyRepositories.
	super tearDown
]
