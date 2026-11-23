/**
 * All DML operations are batched together
 * Any register operation is going to be performed on commitWork method
 * author and date:- yashvir.pathak@intel.com 28/10/2021
 */
public without sharing class UCD_ACM_UnitOfWork implements UCD_ACM_SelectorContracts.IUnitOfWork {
    private Map<String, List<SObject> > mapNewListByType = new Map<String, List<SObject> >();
    private Map<String, Map<Id, SObject> > mapUpdateListByType = new Map<String, Map<Id, SObject> >();
    private Map<String, Map<Id, SObject> > mapDeleteListByType = new Map<String, Map<Id, SObject> >();
    private Map<String, Relationships> mapRelationshipsByType = new Map<String, Relationships>();
    
    /**
     * Method to register single SObject for Insert Operation 
    */
    public void registerNew(SObject record)
    {
        registerNew(record, null, null);
    }

    /**
     * Method to register multiple SObject for Insert Operation 
    */
    public void registerNew(List<SObject> records)
    {
        for (SObject record : records) {
            registerNew(record, null, null);
        }
    }

    /**
     * Method to register single SObject with parent relationship SObject for Insert Operation
     * record - current record
     * relatedToParentField - relationship field in the record
     * relatedToParentRecord - parent SObject for the record
    */
    public void registerNew(SObject record,Schema.SObjectField relatedToParentField, SObject relatedToParentRecord) {
        String sObjectType = record.getSObjectType().getDescribe().getName();
         // If SObject is new, add new record in the map else, update the existing record 

        if( mapNewListByType.get(sObjectType) != null){
            mapNewListByType.get(sObjectType).add(record);
        }else{
             mapNewListByType.put(sObjectType,new List<SObject>{record});
        }

        // register parent relationship for the record 
        if (relatedToParentRecord != null && relatedToParentField != null) {
            registerRelationship(record, relatedToParentField, relatedToParentRecord);
        }
    }

    /**
     * Method to register parent relationship with the record
     * record - current record
     * relatedToField - relationship field in the record
     * relatedTo - parent SObject for the record
    */
    private void registerRelationship(SObject record, Schema.SObjectField relatedToField, SObject relatedTo)
    {
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if (mapRelationshipsByType.get(sObjectType) != Null) {
            mapRelationshipsByType.get(sObjectType).add(record, relatedToField, relatedTo);
        } else {
            // register relationship
            Relationships rela = new Relationships();
            rela.add(record, relatedToField, relatedTo);
            mapRelationshipsByType.put(sObjectType, rela);
        }
    }

    /**
     * Method to register SObject for Update Operation 
    */
    public void registerModified(SObject record) {
        registerModified(record, new List<Schema.SObjectField>());
    }

    /**
     * Method to register SObject to update specific fields (Update operation) 
    */
    public void registerModified(SObject record, List<Schema.SObjectField> fieldsToUpdate) {
        // throw expection if record does not exists
        if (record.Id == null)
            throw new DmlException('New records cannot be registered under update operation');

        // Register the record for update operation
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(mapUpdateListByType == null || mapUpdateListByType.isEmpty()){
            mapUpdateListByType.put(sObjectType, new Map<Id , SObject>{record.Id=> record});
        }
        else if ( !mapUpdateListByType.get(sObjectType).containsKey(record.Id) && fieldsToUpdate.isEmpty()) {            
            mapUpdateListByType.get(sObjectType).put(record.Id, record);
        } else {
            // Update the registered record's fields
            SObject registeredRecord = mapUpdateListByType.get(sObjectType).get(record.Id);
            for (Schema.SObjectField field : fieldsToUpdate) {
                System.debug('field@@@'+field + '@@@record'+record);
                if(record.get(field) != null){
                    System.debug('record.get(field)@@@'+record.get(field));
                    registeredRecord.put(field, record.get(field));
                }
            }
            mapUpdateListByType.get(sObjectType).put(record.Id, registeredRecord);
        }

    }

    /**
     * Method to register SObject for Delete Operation 
    */
    public void registerDeleted(SObject record) {
        // throw expection if record does not exists
        if (record.Id == null)
            throw new DmlException('New records cannot be registered under delete operation');

        // Register the record for delete operation
        String sObjectType = record.getSObjectType().getDescribe().getName();
        if(mapDeleteListByType != null || mapDeleteListByType.isEmpty()){
            mapDeleteListByType.put(sObjectType, new Map<Id , SObject>{record.Id=> record});

        }else{
            mapDeleteListByType.get(sObjectType).put(record.Id, record);

        }
    }

    /**
     * Method to commit all DML Operations 
     * All operations batched together and executed
     * If any operation fails, rollback happens
    */
    public Boolean commitWork() {
        Savepoint sp = Database.setSavepoint();
        try {
            insertDmlByType();
            updateDmlByType();
            deleteDmlByType();
            // return true if all operations are successful
            return true;
        }
        catch (Exception e) {
            // Log exception
            // rollback changes
            System.debug('Exception2==>'+e.getStackTraceString());
            System.debug('Exception2==>'+e.getMessage());

            UCD_ACM_Logger.error('UCD_ACM_UnitOfWork','commitWork','Message: '+e.getMessage()+'. StackTrace: '+e.getStackTraceString(),NULL);
            Database.rollback(sp);
            return false;
        }
    }

    /**
     * Method to execute Insert Operation 
    */
    private void dmlInsert(List<SObject> objList)
    {
        insert objList;
    }

    /**
     * Method to execute Update Operation 
    */
    private void dmlUpdate(List<SObject> objList)
    {
        update objList;
    }

    /**
     * Method to execute delete Operation 
    */
    private void dmlDelete(List<SObject> objList)
    {
        delete objList;
    }

    /**
     * Method to call Insert operation for each SObject present in the map object
    */
    private void insertDmlByType()
    {
        for (String sObjectType : mapNewListByType.keySet()) {
            if (mapRelationshipsByType.get(sObjectType) != null)
                mapRelationshipsByType.get(sObjectType).resolve();
            dmlInsert(mapNewListByType.get(sObjectType));
        }
    }

    /**
     * Method to call Update operation for each SObject present in the map object
    */
    private void updateDmlByType()
    {
        for (String sObjectType : mapUpdateListByType.keySet()) {
            dmlUpdate(mapUpdateListByType.get(sObjectType).values());
        }
    }

    /**
     * Method to call Delete operation for each SObject present in the map object
    */
    private void deleteDmlByType()
    {
        for (String sObjectType : mapDeleteListByType.keySet()) {
            dmlDelete(mapDeleteListByType.get(sObjectType).values());
        }
    }

    /**
     * Relationship class
    */
    private class Relationship {
        public SObject Record;
        public Schema.SObjectField RelatedToField;
        public SObject RelatedTo;
        public void resolve()
        {
            this.Record.put(this.RelatedToField, this.RelatedTo.Id);
        }
    }

    /**
     * Relationships class
     * Contains ADD method to assign relationship 
    */
    private class Relationships {
        private List<Relationship> relationships = new List<Relationship>();
        public void resolve()
        {
            // Resolve relationships
            for (Relationship relationship : relationships) {
                relationship.resolve();
            }
        }

        public void add(SObject record, Schema.SObjectField relatedToField, SObject relatedTo)
        {
            // Relationship to resolve
            Relationship relationship = new Relationship();
            relationship.Record = record;
            relationship.RelatedToField = relatedToField;
            relationship.RelatedTo = relatedTo;
            // Adding into collection
            relationships.add(relationship);
        }
    }

    /**
     * DmlException class
    */
    public class DmlException extends Exception {}
}