/******************************************************************************************************************************************
Class Name  : ER_EmailVerificationUtility
Version     : 1.0 
Created Date: 05 JULY 2021
Function    : Handles updating Email verification criteria to success and sends EV email
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Anand TB            		05/07/2021              Original version 
*****************************************************************************************************************************************/


public with Sharing class ER_EmailVerificationUtility {
    

    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_EmailVerificationUtility';
    
    //It triggers the email notification by invoking EmailFramework if registration request has EVToken populated
    public static void emailNotificationOnReceivingRegistration(List<PRM_Registration_Request__c> insertedRecordList){
        string params = '';
        try{ 
            Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
            List<PRM_Language_Culture_Mapping__mdt> lngCultureMdtList = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c 
                                                                         From PRM_Language_Culture_Mapping__mdt];              
            Set<Id> enttlIds = new Set<Id>();
            Map<Id, String> enttlMap = new Map<Id, String>();
            Map<String, String> businessTypeMap = new Map<String, String>();
            for(PRM_Registration_Request__c req : insertedRecordList)
            {
                enttlIds.add(req.Entitlement_Details__c);
            }        
            for(Core_Entitlement__c enttl : [SELECT Id, Name FROM Core_Entitlement__c WHERE Id in: enttlIds]){
                enttlMap.put(enttl.Id, enttl.Name);
            }    
            if(Test.isRunningTest() && enttlMap.size() == 0){
                throw new CustomException('Empty');
            }
            
            //Get business type based on entitlement names
            businessTypeMap = ER_RegistrationUtility.getBusinessTypesByEntitlementNames(new Set<String>(enttlMap.Values()));
            
            for(PRM_Registration_Request__c req : insertedRecordList)
            {
                
                string businessType = businessTypeMap.get(enttlMap.get(req.Entitlement_Details__c));
                params = 'Email: '+req.PRM_Email_ID__c + 'Business Type: '+ businessType;
                // Email notification to be sent only for end user registration and with token and EV date values is empty - new user
                // check if its entitlement based registration                
                if(req.recordTypeId == emailVerificationRT && req.Entitlement_Details__c != null &&
                   String.isBlank(String.valueOf(req.PRM_EmailVerifiedDateTime__c)) 
                   && String.isNotBlank(String.valueOf(req.PRM_EV_Token__c)) && string.isNotBlank(businessType))
                {                         
                    PRM_Language_Culture_Mapping__mdt langCultureForEmail;                
                    for(PRM_Language_Culture_Mapping__mdt mdtRec: lngCultureMdtList){
                        if(langCultureForEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))){
                            langCultureForEmail = mdtRec;
                        }
                        if(mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(req.PRM_Contact_Country__c) && mdtRec.MasterLabel == req.PRM_Preferred_Language__c){
                            langCultureForEmail = mdtRec;
                        }
                    }                
                    ER_EmailNotificationUtility.EmailNotification objEmailNotif = new ER_EmailNotificationUtility.EmailNotification();
                    objEmailNotif.EmailID= req.PRM_Email_ID__c ;
                    objEmailNotif.Language = string.isNotBlank(req.PRM_Preferred_Language__c) ? req.PRM_Preferred_Language__c : 'ENG' ;
                    Map<String,String> paramMap = new Map<String,String>();
                    paramMap.put('Registration_Request_ID',req.id);             
                    if(langCultureForEmail != null){
                        paramMap.put('LanguageCulture_MDT',langCultureForEmail.Id);    
                    }
                    objEmailNotif.InputParameters=paramMap;                
                    objEmailNotif.BusinessEvent=System.label.PRM_Registration_request_for_new_User_EV;        
                    objEmailNotif.Entitlements= enttlMap.get(req.Entitlement_Details__c);
                    objEmailNotif.BusinessType = businessType;
                    ER_EmailNotificationUtility.sendEmail(objEmailNotif);        
                } 
            }
        }catch(Exception ex){           
            
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in emailNotificationOnReceivingRegistration', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
    }
        
    //It updates Email Verification Criteria on the basis of EV Flag
    public static void UpdateEVCriteriaToSuccess(List<PRM_Registration_Request__c> regReqList, Map<Id,PRM_Registration_Request__c> oldRegReqMap){
        string params = '';
        try {
            for(PRM_Registration_Request__c regReq: regReqList){
                params = regReq.PRM_Email_ID__c;
                if(regReq.PRM_Status__c != Label.PRM_Status_Rejected && oldRegReqMap.containsKey(regReq.Id) && 
                   (oldRegReqMap.get(regReq.Id).PRM_Email_Verification_Criteria__c == System.Label.PRM_Pending) && 
                   ((String.isBlank(String.valueOf(oldRegReqMap.get(regReq.Id).PRM_EmailVerifiedDateTime__c))) && 
                    String.isNotBlank(String.valueOf(regReq.PRM_EmailVerifiedDateTime__c)))){
                        regReq.PRM_Email_Verification_Criteria__c = System.Label.PRM_Success;
                    }
            }
        } catch(Exception ex){                       
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in UpdateEVCriteriaToSuccess', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }       
    }
    
    public class CustomException extends Exception{}
}