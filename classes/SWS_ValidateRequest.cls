/****************************************************************************************************
Apex Class Name : SWS_ValidateRequest
Version         : 1.0 
Created Date    : 2024-03-28
Function        : Validate all the required field based on request type.
Test Class      : SWS_ValidateRequestTest
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Bishal Singh               2024-03-28                Created
*****************************************************************************************************/
public without sharing class SWS_ValidateRequest {
    
    private static final String LOG_ENTRY_ORIGIN   = 'SWS_ValidateRequest';
    private static final String LOG_ENTRY_SCOPE    = 'Validate all the required fields are filled';
    private static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static boolean bypassUpdate = false;
    
    /************************************************************************************************************
    *Method Name : validateRequest
    *Created Date: 2024-03-28
    *Author: Bishal Singh
    *Description : Validate all the required field before submitting it to IDC.
    ************************************************************************************************************/
    @InvocableMethod(label ='validateRequest')
    public static List<String> validateRequest(List<SObject> record) {
        List<String> missingRequiredFieldList = new List<String>();
        List<SWS_Cloud_Credit_Request__c> credRequest = new List<SWS_Cloud_Credit_Request__c>();
        for(SObject request : record){                  
            try{
                Map<String, Object> requiredFieldForRequest = (Map<String, Object>) JSON.deserializeUntyped(Label.SWS_RequiredFieldForRequest);
                Map<String, Schema.SObjectField> fieldAPILabelMap;
                Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get('SWS_Cloud_Credit_Request__c');
                if (sobjectType != null) {
                    fieldAPILabelMap = sobjectType.getDescribe().fields.getMap();
                }
                String requiredField = getRequiredField(requiredFieldForRequest, request);
                String missingField = validateRecord(requiredField,fieldAPILabelMap,request);                
                if (!String.isBlank(missingField)) {               
                    missingRequiredFieldList.add(missingField);
                    credRequest.add(markAsInvalid(String.valueOf(request.Id)));
                }
                
            }catch(Exception ex){
                SWS_Utility.createCoreLogEntry(LOG_ENTRY_ORIGIN,'validateRequest',LOG_ENTRY_SCOPE,'',ex,'SWS_Cloud_Credit_Request__c',LOG_ENTRY_SEVERITY,(String) request.get('Id'));
            }
        }
        if(!credRequest.isEmpty()){
            SWS_Utility.updateByPass();
            Database.SaveResult[] sr = Database.update(credRequest,false);               
            SWS_Utility.updateByPass();
        }
        return missingRequiredFieldList;
    }   
    
    /************************************************************************************************************
    *Method Name : validateRecord
    *Created Date: 2024-08-19
    *Author: Bishal Singh
    *Description : Validate record.
    ************************************************************************************************************/
    private static String validateRecord(String requiredField,Map<String, Schema.SObjectField> fieldAPILabelMap, SObject request){
        String missingField = '';
        Integer itemNumber = 1;
        if (!String.isBlank(requiredField)) {
            for (String field : requiredField.split(';')) {
                if (request.get(field) == null || String.isBlank(String.valueOf(request.get(field)))) {
                    Schema.DescribeFieldResult fldDescribe = fieldAPILabelMap.get(field).getDescribe();
                    missingField += '\n' + itemNumber + ') ' + fldDescribe.getLabel();
                    itemNumber++;
                }
            }
        }        
        return missingField;
    }
    
    /************************************************************************************************************
    *Method Name : getRequiredField
    *Created Date: 2024-04-21
    *Author: Ajinkya(Team Garnet)
    *Description : Set Requierd Field values
    ************************************************************************************************************/
    private static String getRequiredField(Map<String, Object> requiredFieldForRequest, SObject request){
        String requiredField =(String)(requiredFieldForRequest.containsKey((String) request.get('SWS_Request_Type__c')) ? 
                                requiredFieldForRequest.get((String) request.get('SWS_Request_Type__c')) : '');
        
        requiredField = requiredField + (SWS_Core_CRM_Labels__c.getValues('PayloadReqiredField') != null ? SWS_Core_CRM_Labels__c.getValues('PayloadReqiredField').SWS_Value__c : '');
        
        if(!(boolean)request.get('SWS_Submitter_Requster_Email__c')){
            requiredField = requiredField +(SWS_Core_CRM_Labels__c.getValues('SubmitterRequiredFields') != null ? SWS_Core_CRM_Labels__c.getValues('SubmitterRequiredFields').SWS_Value__c : '');
        }
        return requiredField;
    }
    
    /************************************************************************************************************
    *Method Name : markAsInvalid
    *Created Date: 2024-08-19
    *Author: Bishal Singh
    *Description : Check if update required for invalid request.
    ************************************************************************************************************/
    public static SWS_Cloud_Credit_Request__c markAsInvalid(String recordId){
        SWS_Cloud_Credit_Request__c req = new SWS_Cloud_Credit_Request__c();
        req.Id = recordId;
        if(!req.SWS_Is_Submitted_For_Coupon__c && !bypassUpdate){
            req.SWS_Is_Submitted_For_Coupon__c = true;
        }
        return req;
    }
}