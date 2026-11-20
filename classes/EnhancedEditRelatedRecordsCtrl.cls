public with sharing class EnhancedEditRelatedRecordsCtrl {
	@AuraEnabled(cacheable=true)
    public static List<sObject> getRelatedRecords(String parentId,String parentApiName,String objectApiName,String picklistApiName,String sortBy, String fieldSetName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectApiName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        List<RecordType> rc = new List<RecordType>();
        if (!DescribeSObjectResultObj.isAccessible()) {
            return null;
        }
        if (RecordType.SObjectType.getDescribe().isAccessible()) {
            rc = [select Id from RecordType where SObjectType =:objectApiName];
        }
        

        List<String> fieldList = new List<String>();

        for (FieldsetDetails fs: getFieldsetFieldsLocal(objectApiName,fieldSetName)) {
            if(fs.dataType == 'lookupColumn'){
                String rel = fs.fieldName.contains('__c') ? fs.fieldName.replace('__c','__r')+'.Name':
                fs.fieldName.replace('Id','')+'.Name';
                fieldList.add(rel);
            }
            fieldList.add(fs.fieldName);
        }
        String selectString = fieldList.contains(picklistApiName) ? String.join(fieldList, ','):String.join(fieldList, ',')+','+String.escapeSingleQuotes(picklistApiName);
        if(rc != null && !rc.isEmpty()){
            selectString += ',RecordTypeId';
        }
        String query = 'SELECT Id,'+String.escapeSingleQuotes(selectString)+' FROM '+String.escapeSingleQuotes(objectApiName)+' WHERE '+String.escapeSingleQuotes(parentApiName)+'=:parentId'+' ORDER BY '+String.escapeSingleQuotes(sortBy);
        return Database.query(query);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FieldsetDetails> getFieldsetFields(String objectName,String fieldSetName){
        return getFieldsetFieldsLocal(objectName,fieldSetName);
    }

    private static List<FieldsetDetails> getFieldsetFieldsLocal(String objectName,String fieldSetName){
        List<FieldsetDetails> fieldList = new List<FieldsetDetails>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        Map<String,Schema.SObjectField> fsMap = DescribeSObjectResultObj.fields.getMap();
        
         
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields())
        {            
            FieldsetDetails fs = new FieldsetDetails();
            fs.fieldName = (String)fieldSetMemberObj.getFieldPath();
            fs.dataType = String.valueOf(fieldSetMemberObj.getType()).toLowerCase();
            fs.label = String.valueOf(fieldSetMemberObj.getLabel());

            if (fs.dataType == 'picklist') {
                fs.dataType = 'picklistColumn';
                fs.picklistLovs = new List<String>();
                for( Schema.PicklistEntry pickListVal : fsMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().getPicklistValues()){
                    fs.picklistLovs.add(pickListVal.getLabel());
                }  

            }
            else if (fs.dataType == 'reference') {
                fs.dataType = 'lookupColumn';
                fs.lookupNameRef = (fs.fieldName.contains('__c') ? fs.fieldName.replace('__c','_c'):fs.fieldName.replace('Id','_s'));
                fs.refObjName = DescribeSObjectResultObj.fields.getMap().get(fieldSetMemberObj.getFieldPath()).getDescribe().getReferenceTo()[0].getDescribe().getName();
            }
            else if (fs.dataType == 'date') {
                fs.dataType = 'date-local';
            }
            else if (fs.dataType == 'datetime') {
                fs.dataType = 'date';
            } 
            
            fieldList.add(fs);
        }
        
        return fieldList;
    }

    public class FieldsetDetails {
        @AuraEnabled
        public string fieldName;

        @AuraEnabled
        public string dataType;

        @AuraEnabled
        public string label;

        @AuraEnabled
        public List<string> picklistLovs;

        @AuraEnabled
        public string lookupNameRef;

        @AuraEnabled
        public string refObjName;
    }


}