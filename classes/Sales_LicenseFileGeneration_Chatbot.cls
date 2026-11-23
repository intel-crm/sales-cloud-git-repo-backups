/*********************************************************************************************************************
Version       : 1.0
Created Date  : June 2021
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        24-June-2021             Sales_LicenseFileGeneration_Chatbot - For Chatbot to call method to Generate License File.
* ---------------------------------------------------------------------------------------------------------*/
public without sharing class Sales_LicenseFileGeneration_Chatbot {
    public class LicenseFileGenInput {
        @InvocableVariable
        public String ActivationCode_OR_HostId;      
        @InvocableVariable
        public Sales_Host__c HostData ;          
        @InvocableVariable
        public String InputType;               
        @InvocableVariable
        public String temporaryNICID; 
        @InvocableVariable
        public String contactId; 
    }
    public class LicenseFileGenOutput {
        @InvocableVariable
        public Boolean Success_Or_Failure;    
        @InvocableVariable
        public String Computer_SalesforceId;  
    }
    @InvocableMethod(label='Generate License File and Log Entry')
    public static List<LicenseFileGenOutput> generateLicenseFile(List<LicenseFileGenInput> inputData) {       
        List<LicenseFileGenOutput> outputData = new List<LicenseFileGenOutput>();
        Boolean result;
        String pageURL = System.label.Sales_HostDetailUrl;                
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> hostRecordIdSet = new Set<Id>();
        for(LicenseFileGenInput input : inputData){
            if(input.contactId != null){
                contactIdSet.add(input.contactId);
            }
            if(input.inputType == 'LicenseId'){
                hostRecordIdSet.add(input.ActivationCode_OR_HostId);
            }
        }
        Map<Id,Contact> contactMap;
        Map<Id,Sales_License__c> hostRecordMap;
        if(!contactIdSet.isEmpty()){
            contactMap = new Map<Id,Contact>([select id, email, name from contact where Id=:contactIdSet]);
        }
        if(!hostRecordIdSet.isEmpty()){
            hostRecordMap = new Map<Id,Sales_License__c>([SELECT Id,Sales_License_Host_Node_Id__c from Sales_License__c where Id=:hostRecordIdSet]);
        }
        for(LicenseFileGenInput input : inputData) {
            Contact con = contactMap.containsKey(input.contactId) ? contactMap.get(input.contactId) : new Contact();
            String name = con?.Name;
            String emailaddress = con?.Email;
            String LicGenEventType;
            if(input.temporaryNICID!=null){
                LicGenEventType='isTempLicenseGen,'+name+','+emailaddress;
            }else{
                LicGenEventType=','+name+','+emailaddress;
            }
            LicenseFileGenOutput output = new LicenseFileGenOutput();
            if(input.InputType == 'LicenseId' && input.temporaryNICID==null){
                result = Sales_LicenseGenIntegration_Utility.returnHostIdDetail( input.ActivationCode_OR_HostId , input.InputType,LicGenEventType );    
            }
            else if(input.inputType == 'HostId' && input.temporaryNICID==null){ 
                result = Sales_LicenseGenIntegration_Utility.returnHostIdDetail( input.HostData.Id , input.InputType,LicGenEventType );
            }                        
            else if(input.temporaryNICID!=null){                
                result = Sales_LicenseGenIntegration_Utility.returnHostIdDetail(input.HostData.Id , input.InputType,LicGenEventType);  
            }                        
            if(result == true){                
                output.Success_Or_Failure = false;
            }
            else if(result == false){          
                output.Success_Or_Failure = true;
                if(input.InputType == 'HostId'){
                    output.Computer_SalesforceId = pageURL + input.HostData.Id;
                }
                else if(input.inputType == 'LicenseId'){
                    Id hostRecordId = hostRecordMap.containsKey(input.ActivationCode_OR_HostId) ? hostRecordMap.get(input.ActivationCode_OR_HostId).Sales_License_Host_Node_Id__c : null;
                    output.Computer_SalesforceId = pageURL + hostRecordId;
                }
            }
            outputData.add(output);
        } 
        return outputData;
    }       
}