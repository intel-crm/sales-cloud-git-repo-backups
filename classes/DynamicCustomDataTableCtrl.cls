public with sharing class DynamicCustomDataTableCtrl {
    @AuraEnabled(cacheable=true)
    public static List<FieldsetDetails> getFieldsetFields(String objectName,String fieldSetName, Boolean recordsChanged){
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
            fs.editable = fsMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().isUpdateable();
            if(fsMap.get(fieldSetMemberObj.getFieldPath()).getDescribe().isAccessible()){
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
        }
        
        return fieldList;
    }

    @AuraEnabled
    public static List<ErrorDetails> updateRecords(Object data, String objectName) {
        List<ErrorDetails> errorDetails = new List<ErrorDetails>();
        String toTypeCast = 'List<'+objectName+'>';
        List<sObject> recsForUpdate = (List<sObject>) JSON.deserialize(
            JSON.serialize(data),Type.forName(toTypeCast));
        
        Savepoint sp = Database.setSavepoint();
        Database.SaveResult[] srList = Database.update(recsForUpdate, false);

        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                ErrorDetails error = new ErrorDetails();
                error.recordId = sr.getId();
                error.errors = new List<String>();
                error.fields = new List<String>();
                for(Database.Error err : sr.getErrors()) {
                    error.errors.add(err.getMessage());
                    error.fields.addAll(err.getFields());
                }

                errorDetails.add(error);
            }
        }
        if (!errorDetails.isEmpty()) {
            Database.rollback(sp);
        }
        return errorDetails;
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

        @AuraEnabled
        public Boolean editable;
    }

    public class ErrorDetails {
        @AuraEnabled
        public String recordId;

        @AuraEnabled
        public List<String> errors;

        @AuraEnabled
        public List<String> fields;
    }
}