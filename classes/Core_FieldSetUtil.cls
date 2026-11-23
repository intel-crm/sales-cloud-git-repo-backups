public with sharing class Core_FieldSetUtil {
	public static List<Core_Field> getFields(Id recordId, String objectName, String fieldSetName, boolean hideNonAccessibleField) {
        Schema.SObjectType objectType = null;
        system.debug('@@@Obj Name is:'+objectName);
        if (recordId != null) {
            objectType = recordId.getSobjectType();
        }
        else if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }

        return getFields(objectType, fieldSetName, hideNonAccessibleField);
    }
    public static List<Core_Field> getFields(String objectName, String fieldSetName, boolean hideNonAccessibleField) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);

        return getFields(objectType, fieldSetName, hideNonAccessibleField);
    }
    
    private static List<Core_Field> getFields(Schema.SObjectType objectType, String fieldSetName, boolean hideNonAccessibleField) {
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        system.debug('***Fieldsetname is:'+fieldSetName);
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);        
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        List<Core_Field> fields = new List<Core_Field>();
        
        SObjectType schemaType = Schema.getGlobalDescribe().get(String.valueOf(objectType));
    	Map<String, SObjectField> fieldsList = schemaType.getDescribe().fields.getMap();
        
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            if(hideNonAccessibleField){
                if(fieldsList.get(String.valueOf(fsm.getFieldPath())).getDescribe().isAccessible()){
                    Core_Field f = new Core_Field(fsm);
            		fields.add(f);
                }                
            }else{
                Core_Field f = new Core_Field(fsm);
            	fields.add(f);
            }            
        }
        return fields;
    }
}