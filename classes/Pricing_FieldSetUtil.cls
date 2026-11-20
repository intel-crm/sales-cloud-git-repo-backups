public with sharing class Pricing_FieldSetUtil {
	public static List<Pricing_Field> getFields(Id recordId, String objectName, String fieldSetName, boolean hideNonAccessibleField) {
        Schema.SObjectType objectType = null;
        if (recordId != null) {
            objectType = recordId.getSobjectType();
        }
        else if (String.isNotBlank(objectName)) {
            objectType = ((SObject)Type.forName(objectName).newInstance()).getSObjectType();
        }

        return getFields(objectType, fieldSetName, hideNonAccessibleField);
    }
    public static List<Pricing_Field> getFields(String objectName, String fieldSetName, boolean hideNonAccessibleField) {
        Schema.SObjectType objectType = ((SObject)Type.forName(objectName).newInstance()).getSObjectType();

        return getFields(objectType, fieldSetName, hideNonAccessibleField);
    }
    
    private static List<Pricing_Field> getFields(Schema.SObjectType objectType, String fieldSetName, boolean hideNonAccessibleField) {
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);        
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        List<Pricing_Field> fields = new List<Pricing_Field>();
        
        SObjectType schemaType = ((SObject)Type.forName(String.valueOf(objectType)).newInstance()).getSObjectType();
    	Map<String, SObjectField> fieldsList = schemaType.getDescribe().fields.getMap();
        
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            if(hideNonAccessibleField){
                if(fieldsList.get(String.valueOf(fsm.getFieldPath())).getDescribe().isAccessible()){
                    Pricing_Field f = new Pricing_Field(fsm);
            		fields.add(f);
                }                
            }else{
                Pricing_Field f = new Pricing_Field(fsm);
            	fields.add(f);
            }            
        }
        return fields;
    }
}