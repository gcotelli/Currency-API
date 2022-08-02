Class {
	#name : #CurrencyRDBMSMappingConfiguration,
	#superclass : #RDBMSMappingConfiguration,
	#category : #'Currency-System-Model'
}

{ #category : #applying }
CurrencyRDBMSMappingConfiguration >> cull: rdbmsRepository [

	self
		declareTablesIn: rdbmsRepository;
		declareClassModelsIn: rdbmsRepository;
		declareDescriptorsIn: rdbmsRepository
]

{ #category : #private }
CurrencyRDBMSMappingConfiguration >> currencyDescriptor [

	^ ConcreteDescriptorDefinition
		  for: StatusAwareCurrency
		  onTableNamed: self currencyTableName
		  mappingsDefinedBy: { 
				  ( SequentialNumberMappingDefinition onTableNamed: self currencyTableName ).
				  ( DirectMappingDefinition
					    fromAttributeNamed: #uuid
					    toFieldNamed: self uuidFieldName
					    onTableNamed: self currencyTableName
					    conversionDefinedBy: self uuidConversionDefinition ).
				  ( DirectMappingDefinition
					    fromAttributeNamed: #isCirculating
					    toFieldNamed: self isCirculatingFieldName
					    onTableNamed: self currencyTableName ).
				  ( DirectMappingDefinition
					    fromPseudoAttributeNamed: #shortName
					    toFieldNamed: self shortNameFieldName
					    onTableNamed: self currencyTableName ).
				  ( EmbeddedValueOneToOneMappingWithTranslationDefinition
					    forAttributeNamed: #currency
					    translatingFieldsUsingAll: ( self
							      fieldTranslationsForAll: { 
									      self shortNameFieldName.
									      self singularNameFieldName.
									      self pluralNameFieldName.
									      self iso4217CodeFieldName.
									      self issueDateFieldName.
									      self subUnitDenominatorFieldName }
							      between: self currencyTableName
							      and: #EMBEDDED_CURRENCy ) ) }
]

{ #category : #private }
CurrencyRDBMSMappingConfiguration >> currencyFieldDefinitions [

	^ {  CharacterFieldDefinition named: self shortNameFieldName sized: 6.
		  CharacterFieldDefinition named: self singularNameFieldName sized: 8000.
		  CharacterFieldDefinition named: self pluralNameFieldName sized: 8000.
		  IntegerFieldDefinition named: self subUnitDenominatorFieldName.
		  CharacterFieldDefinition nullableNamed: self iso4217CodeFieldName sized: 3.
		  DateFieldDefinition named: self issueDateFieldName }
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> currencyTableName [

	^ 'CURRENCY'
]

{ #category : #applying }
CurrencyRDBMSMappingConfiguration >> declareClassModelsIn: rdbmsRepository [

	rdbmsRepository
		beAwareOfClassModelDefinedBy:
			( ClassModelDefinition for: StatusAwareCurrency attributesDefinedBy: { 
						  ( BasicAttributeDefinition named: #sequentialNumber ).
						  ( BasicAttributeDefinition named: #uuid ).
						  ( BasicAttributeDefinition named: #isCirculating ).
						  ( TypedAttributeDefinition named: #currency typed: Currency ).
						  ( BasicAttributeDefinition named: #shortName ) } );
		beAwareOfClassModelDefinedBy: ( ClassModelDefinition for: Currency attributesDefinedBy: { 
						  ( BasicAttributeDefinition named: #shortName ).
						  ( BasicAttributeDefinition named: #singularName ).
						  ( BasicAttributeDefinition named: #pluralName ).
						  ( BasicAttributeDefinition named: #subUnitDenominator ).
						  ( BasicAttributeDefinition named: #iso4217CodeOptional ).
						  ( BasicAttributeDefinition named: #issueDate ) } )
]

{ #category : #applying }
CurrencyRDBMSMappingConfiguration >> declareDescriptorsIn: rdbmsRepository [

	rdbmsRepository
		beAwareOfDescriptorDefinedBy: self embeddedCurrencyDescriptor;
		beAwareOfDescriptorDefinedBy: self currencyDescriptor
]

{ #category : #applying }
CurrencyRDBMSMappingConfiguration >> declareTablesIn: rdbmsRepository [

	| fieldDefinitions |

	fieldDefinitions := { SequentialNumberFieldDefinition new.
		                   CharacterFieldDefinition named: self uuidFieldName sized: 36.
		                   BooleanFieldDefinition named: self isCirculatingFieldName }.

	rdbmsRepository
		beAwareOfTableDefinedBy: ( RealTableDefinition
				  named: self currencyTableName
				  fieldsDefinedBy: fieldDefinitions , self currencyFieldDefinitions );
		beAwareOfTableDefinedBy: ( ImaginaryTableDefinition
				  named: self embeddedCurrencyTableName
				  fieldsDefinedBy: self currencyFieldDefinitions )
]

{ #category : #private }
CurrencyRDBMSMappingConfiguration >> embeddedCurrencyDescriptor [

	^ ConcreteDescriptorDefinition
		  for: Currency
		  onTableNamed: self embeddedCurrencyTableName
		  mappingsDefinedBy: { 
				  ( DirectMappingDefinition
					    fromAttributeNamed: #shortName
					    toFieldNamed: self shortNameFieldName
					    onTableNamed: self embeddedCurrencyTableName ).
				  ( DirectMappingDefinition
					    fromAttributeNamed: #singularName
					    toFieldNamed: self singularNameFieldName
					    onTableNamed: self embeddedCurrencyTableName ).
				  ( DirectMappingDefinition
					    fromAttributeNamed: #pluralName
					    toFieldNamed: self pluralNameFieldName
					    onTableNamed: self embeddedCurrencyTableName ).
				  ( DirectMappingDefinition
					    fromAttributeNamed: #subUnitDenominator
					    toFieldNamed: self subUnitDenominatorFieldName
					    onTableNamed: self embeddedCurrencyTableName ).
				  ( self
					    mappingForOptional: #iso4217CodeOptional
					    to: self iso4217CodeFieldName
					    on: self embeddedCurrencyTableName ).
				  ( DirectMappingDefinition
					    fromAttributeNamed: #issueDate
					    toFieldNamed: self issueDateFieldName
					    onTableNamed: self embeddedCurrencyTableName ) }
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> embeddedCurrencyTableName [

	^ #EMBEDDED_CURRENCY
]

{ #category : #private }
CurrencyRDBMSMappingConfiguration >> fieldTranslationsForAll: fieldNames between: realTableName and: imaginaryTableName [

	^ fieldNames collect: [ :fieldName | 
		  TableFieldTranslationDefinition
			  translatingFieldNamed: fieldName
			  onTableNamed: realTableName
			  toFieldNamed: fieldName
			  onTableNamed: imaginaryTableName
		  ]
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> isCirculatingFieldName [

	^ 'is_circulating'
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> iso4217CodeFieldName [

	^ 'iso_4217_code'
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> issueDateFieldName [

	^ 'issue_date'
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> pluralNameFieldName [

	^ 'plural_name'
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> shortNameFieldName [

	^ 'short_name'
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> singularNameFieldName [

	^ 'singular_name'
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> subUnitDenominatorFieldName [

	^ 'sub_unit_denominator'
]

{ #category : #'private - accessing' }
CurrencyRDBMSMappingConfiguration >> uuidFieldName [

	^ 'uuid'
]
