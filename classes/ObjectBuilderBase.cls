public abstract class ObjectBuilderBase {

	static {
		if (!Test.isRunningTest()) {
			throw new ObjectBuilderBaseException('Class ObjectBuilderBase can only be used in tests');
		}
	}
	
	private SObject record;
	protected fflib_SObjectUnitOfWork workUnit;

	private Map<SObjectField, List<ObjectBuilderBase>> registeredChildren = new Map<SObjectField, List<ObjectBuilderBase>>();
	private Map<SObjectField, ObjectBuilderBase> registeredParents = new Map<SObjectField, ObjectBuilderBase>();
	private Boolean isMocked = false;

	protected ObjectBuilderBase(Schema.SObjectType objType) {
		record = objType.newSObject();
	}

	protected ObjectBuilderBase(SObject sObj) {
		this.record = sObj;
	}

	protected ObjectBuilderBase(Schema.SObjectType objType, fflib_SObjectUnitOfWork workUnit) {
		record = objType.newSObject();
		this.workUnit = workUnit;
		registerStandalone(record);
		setDefaultData();
	}

	protected ObjectBuilderBase(SObject sObj, fflib_SObjectUnitOfWork workUnit) {
		record = sObj;
		this.workUnit = workUnit;
		registerStandalone(record);
	}

	/**
	 * Override in BLD_ class to set default data (e.g. required fields)
	 * on builder initialization.
	 */
	protected virtual void setDefaultData() {}

	public void registerDirty(){
		workUnit.registerDirty(this);
	}

	public ObjectBuilderBase setField(Schema.SObjectField field, Object value) {
		record.put(field,value);
		return this;
	}

	public Boolean isInserted() {
		return !String.isBlank(record.Id);
	}

	public SObject getRecord() {
		return record;
	}

	/**
	 * Mocks record with all relations and Ids.
	 *
	 * @return Mocked SObject record
	 */
	public SObject mock() {
		if (isMocked) {
			return record;
		}
		mockChildRelations();
		mockParentRelations();
		record.Id = fflib_IDGenerator.generate(record.getSObjectType());
		isMocked = true;
		return record;
	}

	private void mockChildRelations() {
		String sObjectName = record.getSObjectType().getDescribe().getName();
		Type recordsListType = Type.forName('List<' + sObjectName + '>');
		List<SObject> recordsList = ((List<SObject>) recordsListType.newInstance());
		recordsList.add(record);

		for (SObjectField childField : registeredChildren.keySet()) {
			List<ObjectBuilderBase> childBuilders = registeredChildren.get(childField);
			List<SObject> childRecords = new List<SObject>();
			for (Integer i = 0, j = childBuilders.size(); i < j; i++) {
				ObjectBuilderBase childBuilder = childBuilders[i];
				childRecords.add(childBuilder.mock());
			}
			recordsList[0] = ((List<SObject>) fflib_ApexMocksUtils.makeRelationship(
				recordsListType,
				recordsList,
				childField,
				new List<List<SObject>> {
					childRecords
				}
			))[0];
		}
		record = recordsList[0];
	}

	private void mockParentRelations() {
		for (SObjectField parentRelationField : registeredParents.keySet()) {
			ObjectBuilderBase parentBuilder = registeredParents.get(parentRelationField);
			SObject parentRecord = parentBuilder.mock();
			record.put(parentRelationField, parentRecord.Id);
			record.putSObject(parentRelationField.getDescribe().getRelationshipName(), parentRecord);
		}
	}

	public Id getRecordId() {
		return (Id)record.get('Id');
	}

	public ObjectBuilderBase refreshFromDB(){
		refreshFromDB(new Set<String>());
		return this;
	}

	public ObjectBuilderBase refreshFullFromDB(){
		String objectName = String.valueOf(getRecordId().getSobjectType());
		Set<String> allFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet();
		refreshFromDB(allFields);
		return this;
	}

	public ObjectBuilderBase refreshFromDB(Set<String> additionalFields){ 
		if(isInserted()){
			record = fetchSObject(additionalFields);
		}  
		return this; 
	}

	private SObject fetchSObject(Set<String> additionalFields){
		Set<String> queryFields = new Set<String>(record.getPopulatedFieldsAsMap().keySet());
		queryFields.addAll(additionalFields);
		Set<String> uniqueFields = new Set<String>();
		for(String field : queryFields){
			uniqueFields.add(field.toUpperCase());
		}
		List<String> fields = new List<String>(uniqueFields); 
           
		return Database.query(	'SELECT ' + String.join(fields, ',') + ' FROM ' 
								+ String.valueOf(record.getSObjectType()) + ' WHERE Id =\''
								+ String.valueOf(record.get('Id')) + '\'' );   
	}

	private void registerStandalone(SObject sObj) {
		String sObjectType = sObj.getSObjectType().getDescribe().getName();
		if (sObjectType.length() > 3 && sObjectType.right(3) == '__e') {
			workUnit.registerPublishBeforeTransaction(sObj);
		} else if (record.Id == null) {
			workUnit.registerNew(sObj);
		} else {
			workUnit.registerDirty(sObj);
		}
	}

	public ObjectBuilderBase addChild(Schema.SObjectField field, ObjectBuilderBase childObjBuilder) {
		workUnit.registerRelationship(childObjBuilder.getRecord(), field, record);
		if (!registeredChildren.containsKey(field)) {
			registeredChildren.put(field, new List<ObjectBuilderBase>());
		}
		registeredChildren.get(field).add(childObjBuilder);
		return this;
	}

	public ObjectBuilderBase setRelation(Schema.SObjectField field, ObjectBuilderBase parentObjBuilder) {
		if(!parentObjBuilder.isInserted()) {
			workUnit.registerRelationship(record, field, parentObjBuilder.getRecord());
		} else {
			setField(field,parentObjBuilder.getRecord().Id);
		}
		registeredParents.put(field, parentObjBuilder);
		return this;
	}

	public virtual ObjectBuilderBase commitWork() {
		workUnit.commitWork();
		return this;
	}

	public static fflib_SObjectUnitOfWork getNewUnitOfWork() {
		return getNewUnitOfWork(new List<SObjectType>());
	}

	/**
	 * Is used to include additional SObject types, which cannot be added permanently
	 * due to 'Entity is not API accessible' error.
	 *
	 * @param additionalTypes list of SObject types to be added to base list
	 * @return fflib_SObjectUnitOfWork
	 */
	public static fflib_SObjectUnitOfWork getNewUnitOfWork(List<Schema.SObjectType> additionalTypes) {
		List<Schema.SObjectType> registeredTypes = Sales_Application.unitOfWorkRegisteredTypes;
		registeredTypes.addAll(additionalTypes);
		return new fflib_SObjectUnitOfWork(registeredTypes);
	}

	public class ObjectBuilderBaseException extends Exception {} 
}