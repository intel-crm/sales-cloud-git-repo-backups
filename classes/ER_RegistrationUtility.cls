/******************************************************************************************************************************************
Class Name  : ER_RegistrationUtility
Version     : 1.0 
Created Date: 05 JULY 2021
Function    : Contains all common funtions for registrations
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Anand TB                05/07/2021              Original version 
*****************************************************************************************************************************************/


public without sharing class ER_RegistrationUtility {
    
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_RegistrationUtility';
    
    //Gets registration type based on registration request received
    public static set<string> GetRegistrationTypes(List<PRM_Registration_Request__c> requests) {
        set<string> registrationTypes =  new set<string>(); 
        for(PRM_Registration_Request__c request : requests) {
            if(request.Entitlement_Details__c != null) {
                registrationTypes.add(Label.RegistrationTypeEntitlement);
            }
            else if(request.PRM_Channel_Program__c != null) {
                registrationTypes.add(Label.RegistrationTypeProgram);
            }
            else {
                registrationTypes.add(Label.RegistrationTypeGeneric);
            }
        }        
        return registrationTypes;
    }
    
    public static Map<string, string> getBusinessTypesByEntitlementNames(Set<String> enttlNames){
        Map<String, String> businessTypeMap = new Map<String, String>();
        if( Trigger_Execution__mdt.getInstance('PRM_ERRegClassToggle').Active__c || (enttlNames != null && !enttlNames.isEmpty()) ){
            for(PRM_VXEnttlmntMatrix__c matrix :   [ SELECT Business_Types__r.Name, Business_Types__r.Business_Type_Code__c,
            PRM_Entitlement_Id__r.Name
            FROM PRM_VXEnttlmntMatrix__c 
            WHERE PRM_Entitlement_Id__r.Name in : enttlNames
            AND Business_Types__r.Is_Active__c = true]) {
                if(!businessTypeMap.containsKey(matrix.PRM_Entitlement_Id__r.Name)) {
                    businessTypeMap.put(matrix.PRM_Entitlement_Id__r.Name, matrix.Business_Types__r.Name);
                }                
            }
        }
        return businessTypeMap;
    }
    
    /*Commented as part of EBR framework and implemented the logic with Flows
    //Sets EV criteria, language and matching contact
    public static void SetEVAndLanguage(List<PRM_Registration_Request__c> registrationRequests) {
        Set<String> emails = new Set<String>();
        Group queueID = [Select ID from Group where Type =: System.Label.PRM_QueueGroup and DeveloperName =: System.Label.PRM_Manual_Approval_Members Limit 1];
        Map<String,Contact> emailMap = new Map<String,Contact>();
        
        for(PRM_Registration_Request__c request: registrationRequests){
            emails.add(request.PRM_Email_ID__c);
        }
        
        for(Contact con: [Select Id, Email from Contact where Email in: emails]){
            emailMap.put(con.Email,con);
        }
        
        for(PRM_Registration_Request__c request: registrationRequests){
            if(String.isBlank(request.PRM_Preferred_Language__c))
            {               
                request.PRM_Preferred_Language__c = System.Label.PRM_ENG ; 
            }
            
            if(emailMap!= null && emailMap.containsKey(request.PRM_Email_ID__c) && String.isBlank(request.PRM_Matching_Contact__c)){
                request.PRM_Matching_Contact__c = emailMap.get(request.PRM_Email_ID__c).Id;
            }
            
            // TODO: Not sure applicable for all business types
            //request.OwnerId = queueID.id; 
            //request.PRM_EV_Token_Renewed_Date__c = datetime.now();
            
            //TWC722-734 - Commented as part of CiDaas -ATB
            if(String.isNotBlank(String.valueOf(request.PRM_EmailVerifiedDateTime__c))){
                request.PRM_Email_Verification_Criteria__c = System.Label.PRM_Success;
            }
        }
    }*/
    
    //Added for Assigning Default value for 'Assigned to' field on New Registration
    //Added on 4/5/2022 by Gaurav
    Public static void setAssignedTo(List<PRM_Registration_Request__c> registrationRequests){
        List<String> newReg_AssignTo = new List<String>();
        String params = '';
        
        try{
                for(User asUser : [Select id, name from User where name =: System.Label.Assigned_to_Dafault and IsActive = true]){
                    newReg_AssignTo.add(asUser.id);           
                }
                
               
                for(PRM_Registration_Request__c request: registrationRequests){
                   
                     if(Test.isRunningTest() && request.PRM_Address_Line_2__c == 'exception'){
                        throw new ER_ErrorUtility.CustomException('exception');
                    }
            
                    if(request.Entitlement_Details__c != null && newReg_AssignTo.size() > 0)
                    {
                        request.Assigned_To__c = newReg_AssignTo[0];
                    }
                }
          }
            catch(Exception ex)
            {
                ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();custEx.Message = ex.getMessage(); custEx.Cause = ex.getCause();custEx.StackTraceString = ex.getStackTraceString();custEx.LineNumber = ex.getLineNumber();custEx.TypeName = ex.getTypeName();ER_ErrorUtility.createLogEntry('Error while updating Assigned To field', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
            }
    }
   
    public static void autoApproveRegReq(List<Contact_Business_Types__c> newCBTs, Map<Id, Contact_Business_Types__c> oldMap)
    {
        string params = '';
        List<PRM_Registration_Request__c> reqToBeUpdated = new List<PRM_Registration_Request__c>();
        
        try {
            boolean isUpdated = false;           
            for(Contact_Business_Types__c cbt : newCBTs) 
            {
                params = params + 'ContactId-'+ cbt.Contact__c + '-Business Type Id-'+cbt.Business_Types__c+';';
                Contact_Business_Types__c oldCBT = (Contact_Business_Types__c)Trigger.oldMap.get(cbt.Id);
                if((oldCBT.Status__c == System.Label.ER_Approval_Pending && cbt.Status__c == System.Label.ER_Approved)) 
                {
                    isUpdated = true;
                }                
            }
            if(isUpdated)
            {
                Set<String> emailSet = new Set<String>();
                for(Contact_Business_Types__c cbt : [SELECT Contact__r.Email FROM Contact_Business_Types__c WHERE Status__c = 'Approved' AND Id =: newCBTs])
                {
                    if (cbt.Contact__r.Email != null) {
                       emailSet.add(cbt.Contact__r.Email);
                    }
                }  
                List<PRM_Registration_Request__c> requests =[SELECT ID,Current_Status__c,PRM_Status__c FROM PRM_Registration_Request__c WHERE Current_Status__c = 'Auto-Approval Pending' AND PRM_Email_ID__c =:emailSet  ORDER BY LastModifiedDate DESC];
                for(PRM_Registration_Request__c req : requests){
                    req.Current_Status__c = 'Auto-Approval Approved';
                    req.PRM_Status__c = 'Approved';
                    reqToBeUpdated.add(req);
                }
                
                //if(reqToBeUpdated.size() > 0)
                //{
                    if(reqToBeUpdated.size() > 0 && Schema.sObjectType.PRM_Registration_Request__c.isUpdateable())
                    {
                        Update reqToBeUpdated;
                    }
               //}
            }
        }
        catch(Exception ex) 
        {
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in autoApproveRegReq', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
    }
}