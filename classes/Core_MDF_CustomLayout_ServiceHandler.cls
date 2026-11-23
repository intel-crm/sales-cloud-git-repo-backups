public without sharing class Core_MDF_CustomLayout_ServiceHandler {
    public static void validRecord(List<Core_MDF_Custom_Layout_Configurations__c> customLayoutNewList, Boolean isInsert, Boolean isUpdate, List<Core_MDF_Custom_Layout_Configurations__c> customLayoutOldList){
        Map<String, Schema.SObjectType> objMap = Schema.getGlobalDescribe();//ATHR fix
        for(Integer i = 0 ; i < customLayoutNewList.size() ; i++) {
            String errorMsg = 'Please Enter';
            Boolean isError = true;
            If(isInsert || (isUpdate && customLayoutNewList[i].Core_MDF_Object_API_Name_txt__c != customLayoutOldList[i].Core_MDF_Object_API_Name_txt__c)){ 
                //Map<String, Schema.SObjectType> objMap = Schema.getGlobalDescribe();
                //If(objMap.containsKey(customLayoutNewList[i].Core_MDF_Object_API_Name_txt__c)) {
                    if (!objMap.containsKey(customLayoutNewList[i].Core_MDF_Object_API_Name_txt__c)) { //ATHR Fix WW19
                        errorMsg += ' Valid Object API Name,';
                        isError = false;
                        continue; 
                    }
                    If(isInsert || (isUpdate && customLayoutNewList[i].Core_MDF_Record_Type_Name_txt__c != customLayoutOldList[i].Core_MDF_Record_Type_Name_txt__c)){
                        Boolean isValidRecordType = validateRecordTypeName(customLayoutNewList[i].Core_MDF_Object_API_Name_txt__c, customLayoutNewList[i].Core_MDF_Record_Type_Name_txt__c);
                        If(!isValidRecordType){
                            errorMsg = errorMsg + ' Valid Record Type Name,';
                            isError = false;
                        }
                    }
                    If(isInsert || (isUpdate && customLayoutNewList[i].Core_MDF_Field_API_Name_txt__c != customLayoutOldList[i].Core_MDF_Field_API_Name_txt__c)){
                        Boolean isValidField = validateFieldName(customLayoutNewList[i].Core_MDF_Object_API_Name_txt__c, customLayoutNewList[i].Core_MDF_Field_API_Name_txt__c);
                        If(!isValidField){
                            errorMsg = errorMsg + ' Valid Field API Name,';
                            isError = false;
                        }
                    }
                /*} else {
                    errorMsg = errorMsg + ' Valid Object API Name,';
                    isError = false;
                }*/
            }
            If(isUpdate && customLayoutNewList[i].Core_MDF_Object_API_Name_txt__c == customLayoutOldList[i].Core_MDF_Object_API_Name_txt__c
                    && customLayoutNewList[i].Core_MDF_Record_Type_Name_txt__c != customLayoutOldList[i].Core_MDF_Record_Type_Name_txt__c){
                        Boolean isValidRecordType =validateRecordTypeName(customLayoutOldList[i].Core_MDF_Object_API_Name_txt__c, customLayoutNewList[i].Core_MDF_Record_Type_Name_txt__c);
                        If(!isValidRecordType){
                            errorMsg = errorMsg + ' Valid Record Type Name,';
                            isError = false;
                        }
                    }   
            If(isUpdate && customLayoutNewList[i].Core_MDF_Object_API_Name_txt__c == customLayoutOldList[i].Core_MDF_Object_API_Name_txt__c
                    && customLayoutNewList[i].Core_MDF_Field_API_Name_txt__c != customLayoutOldList[i].Core_MDF_Field_API_Name_txt__c){
                        Boolean isValidField =validateFieldName(customLayoutOldList[i].Core_MDF_Object_API_Name_txt__c, customLayoutNewList[i].Core_MDF_Field_API_Name_txt__c);
                        If(!isValidField){
                            errorMsg = errorMsg + ' Valid Field API Name,';
                            isError = false;
                        }
                    }
                    
            errorMsg = errorMsg.removeEnd(',');
            If(isError == false){
                customLayoutNewList[i].Id.addError(errorMsg);
            }       
        }
    }
    
    private static Boolean validateFieldName(String objetAPIName, String fieldAPIName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objetAPIName).getDescribe().fields.getMap();
        If(!fieldMap.containsKey(fieldAPIName)) {
            return false;
        } else {
            return true;
        }
    }

    private static Boolean validateRecordTypeName(String objetAPIName, String recordTypeName){
        System.debug('tesAmey124 '+recordTypeName);
        Map<String, Schema.RecordTypeInfo> recTypeMap = Schema.getGlobalDescribe().get(objetAPIName).getDescribe().getRecordTypeInfosByName();
        If(!recTypeMap.containsKey(recordTypeName)) {
            return false;
        } else {
            return true;
        }
    }
}