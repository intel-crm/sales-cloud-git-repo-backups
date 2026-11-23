/******************************************************************************************************************************************
Class Name  : ER_DuplicationUtility
Version     : 1.0 
Created Date: 05 JULY 2021
Function    : Handles Logic to check duplication for request and CIM call
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Anand TB            05/07/2021              Original version 
*****************************************************************************************************************************************/

public without sharing class ER_DuplicationUtility {
    
    /*Commented as part of EBR framework and implemented the logic with Flows
    // Checks if there is duplicate regisrtation request and rejects duplicate
    public static void rejectDuplicates(List<PRM_Registration_Request__c> regReqList,Map<Id, PRM_Registration_Request__c> oldRequestMap){
        List<PRM_Registration_Request__c> duplicateRequest = new List<PRM_Registration_Request__c>();
        Boolean isDuplicate;
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        Id adminRegistrationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
        
        if(regReqList.size()>0){
            for(PRM_Registration_Request__c reg_Request : regReqList) {
                // For admin and 2nd step of registration
                if((oldRequestMap == null && (reg_Request.RecordTypeId == adminRegistrationRT || reg_Request.RecordTypeId == accCreateRequestId) && reg_Request.PRM_Status__c == 'New') || 
                   (reg_Request.RecordTypeId == accCreateRequestId && oldRequestMap != null && oldRequestMap.containsKey(reg_Request.Id) && 
                    oldRequestMap.get(reg_Request.Id).RecordTypeId == emailVerificationRT && reg_Request.PRM_Status__c == 'New')){
                        
                        // Handle null, empty and without passing attribute
                        if(reg_Request.PRM_Account_Name__c != null && String.isNotBlank(reg_Request.PRM_Account_Name__c)  
                           && reg_Request.PRM_Contact_Login_ID__c != null && String.isNotBlank(reg_Request.PRM_Contact_Login_ID__c) 
                           && reg_Request.PRM_Email_ID__c != null && String.isNotBlank(reg_Request.PRM_Email_ID__c)
                           && reg_Request.PRM_Status__c != null && String.isNotBlank(reg_Request.PRM_Status__c)){
                             if(Schema.sObjectType.PRM_Registration_Request__c.isAccessible()){  
                               duplicateRequest = [Select Id,Name,RecordTypeId,PRM_Account_Name__c,PRM_Contact_Login_ID__c,PRM_Email_ID__c,PRM_Partner_Type__c,PRM_Status__c,PRM_Contact_Salesforce_ID__c
                                                   from PRM_Registration_Request__c where PRM_Account_Name__c =: reg_Request.PRM_Account_Name__c AND 
                                                   PRM_Contact_Login_ID__c =: reg_Request.PRM_Contact_Login_ID__c AND PRM_Email_ID__c =: reg_Request.PRM_Email_ID__c
                                                   AND Entitlement_Details__c =: reg_Request.Entitlement_Details__c
                                                   AND (((PRM_Status__c != :Label.PRM_Status_Rejected) OR (RecordTypeId =:adminRegistrationRT)) AND CreatedDate = LAST_N_DAYS:1) AND
                                                   RecordTypeId =: reg_Request.RecordTypeId];
                                 }
                           }
                        
                        if(duplicateRequest.size()>0){
                            isDuplicate = false;
                            if(String.IsNotBlank(reg_Request.PRM_Contact_Salesforce_ID__c)){
                                for(PRM_Registration_Request__c dupRegReq: duplicateRequest){
                                    if(dupRegReq.PRM_Contact_Salesforce_ID__c == reg_Request.PRM_Contact_Salesforce_ID__c){
                                        isDuplicate = true;
                                        break;
                                    }
                                }
                            }else{
                                isDuplicate = true;
                            }
                            if(isDuplicate == true){
                               
                                reg_Request.PRM_Status__c = Label.PRM_Status_Rejected;
                                reg_Request.PRM_Status_Reason__c = Label.PRM_Duplicate_Request;
                                if(reg_Request.RecordTypeId == accCreateRequestId){
                                    reg_Request.PRM_isSubmitted__c = true;
                                }
                            }
                        }                 
                    }
            }                      
        }        
    }*/
    
    // Checks with CIM system and sets dup status to either No dup, full dup or part dup
    /*public static void DupCheckOld(List<PRM_Registration_Request__c> regReqList,Map<Id,PRM_Registration_Request__c> oldRegReqMap){
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        String oldRequestStatus = '';
        PRM_CIM_Request__mdt cimMdt = [Select Id, MasterLabel,API_Key__c, PRM_Async_Id__c, PRM_Calling_System__c, PRM_Restriction_Level__c, PRM_Max_Records__c, PRM_Max_Score__c, PRM_Min_Score__c from PRM_CIM_Request__mdt where MasterLabel =: System.Label.PRM_Dupe_Scores];
        for(PRM_Registration_Request__c regReq : regReqList){
            List<ER_SearchAccounts> lstSearchAccountObj = new List<ER_SearchAccounts>();
            List<PRM_CIMSearchResults__c> listOfCimResult = new List<PRM_CIMSearchResults__c>();
            ER_SearchCIMAccounts erCIMCallout = new ER_SearchCIMAccounts();
            Map<String,String> countryMap = new map<String,String>();
            string billingCountryForCallout='';
            for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                countryMap.put(allCountries.ISO_Code__c, allCountries.Country_Code__c);
            }
            
            if(regReq.PRM_Country__c!=null && regReq.PRM_Country__c.length() == 3 && countryMap != null && countryMap.containsKey(regReq.PRM_Country__c)){
                billingCountryForCallout = countryMap.get(regReq.PRM_Country__c);
                
               
            } 
            //TODO: Call CIM API when we get Account in request?  
            oldRequestStatus = oldRegReqMap.get(regReq.Id).PRM_Dup_Status__c;
            if(((regReq.recordTypeId == accountCreateRequestRT) && regReq.PRM_Status__c != Label.PRM_Status_Rejected && String.isNotBlank(regReq.PRM_Account_Name__c) && String.isNotBlank(regReq.PRM_Address_Line_1__c) && String.isNotBlank(regReq.PRM_Zip_Postal_Code__c) && String.isNotBlank(regReq.PRM_City__c) && ((String.isBlank(regReq.PRM_Dup_Status__c)) || ( (regReq.PRM_Dup_Status__c == 'NOT PROC') && String.isNotBlank(oldRequestStatus) && (oldRequestStatus == 'ERROR')))) ||
               ((regReq.recordTypeId == accountCreateRequestRT) && (String.isNotBlank(regReq.PRM_Salesforce_ID__c)) && ((String.isBlank(regReq.PRM_Dup_Status__c)) || ((regReq.PRM_Dup_Status__c == 'NOT PROC') && String.isNotBlank(oldRequestStatus) && (oldRequestStatus == 'ERROR'))))){
                   
                   //Calling CIM API to get Matching Account Score Results
                   listOfCimResult = erCIMCallout.getCimResults(regReq.PRM_Account_Name__c, regReq.PRM_Address_Line_1__c, regReq.PRM_Zip_Postal_Code__c,regReq.PRM_City__c,billingCountryForCallout,regReq.PRM_State_Province__c,null,null,regReq.PRM_Account_URL__c,regReq.PRM_Email_ID__c,null, false);
                   
                   if(Test.isRunningTest()){
                       listOfCimResult = ER_DuplicationUtility_Test.getCIMResults(55);
                   }
                  
                   if(listOfCimResult!= null && listOfCimResult.size()>0){
                       double maxValue=0;
                       for(PRM_CIMSearchResults__c res : listOfCimResult){
                           if(maxValue<res.PRM_SearchScore_Nbr__c)
                           {
                               maxValue=res.PRM_SearchScore_Nbr__c;
                           }
                       }
                      
                       if(maxValue < Integer.valueOf(cimMdt.PRM_Min_Score__c)){
                           regReq.PRM_Dup_Status__c = System.Label.PRM_Nodup;
                           regReq.PRM_DeDup_Criteria__c = System.Label.PRM_Success;
                           
                       }
                       
                       else if(maxValue >= Integer.valueOf(cimMdt.PRM_Min_Score__c) && maxValue < Integer.valueOf(cimMdt.PRM_Max_Score__c)){
                           regReq.PRM_Dup_Status__c = System.Label.PRM_Partdup;
                           regReq.PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
                          
                           
                       }
                       else{
                           regReq.PRM_Dup_Status__c = System.Label.PRM_Fulldup;
                           regReq.PRM_DeDup_Criteria__c = System.Label.PRM_Fail;
                           
                       }
                       
                   }
                   else {
                       regReq.PRM_Dup_Status__c = System.Label.PRM_Nodup;
                       regReq.PRM_DeDup_Criteria__c = System.Label.PRM_Success;
                       
                   }
               }            
        }
        
    }*/
    
    // Checks with CIM system and sets dup status to either No dup, full dup or part dup
    public static void DupCheck(List<PRM_Registration_Request__c> regReqList,Map<Id,PRM_Registration_Request__c> oldRegReqMap){
        Id accountCreateRequestRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        String oldRequestStatus = '';
        PRM_Registration_Request__c regReq = regReqList[0];
        oldRequestStatus = oldRegReqMap!= null ? oldRegReqMap.get(regReq.Id).PRM_Dup_Status__c : ''; 
        
        if(((regReq.recordTypeId == accountCreateRequestRT) && regReq.PRM_Status__c != Label.PRM_Status_Rejected && String.isNotBlank(regReq.PRM_Account_Name__c) && String.isNotBlank(regReq.PRM_Address_Line_1__c) && String.isNotBlank(regReq.PRM_Zip_Postal_Code__c) && String.isNotBlank(regReq.PRM_City__c) && ((String.isBlank(regReq.PRM_Dup_Status__c)) || ( (regReq.PRM_Dup_Status__c == 'NOT PROC') && String.isNotBlank(oldRequestStatus) && (oldRequestStatus == 'ERROR')))) ||
           ((regReq.recordTypeId == accountCreateRequestRT) && (String.isNotBlank(regReq.PRM_Salesforce_ID__c)) && ((String.isBlank(regReq.PRM_Dup_Status__c)) || ((regReq.PRM_Dup_Status__c == 'NOT PROC') && String.isNotBlank(oldRequestStatus) && (oldRequestStatus == 'ERROR'))))){              	
               
               Id queueId = System.enqueueJob(new ER_DupCheck_CIMCallout(regReq,0,null,null,null,true));               
           }
    }   
}