public without sharing class ER_CheckAutoapprovalCriteria 
{
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_CheckAutoapprovalCriteria';
    
    @InvocableMethod(label='Auto Approval Check' description='Check for Auto Approvals for EBR' category= 'New Registration')
    public static void CheckAutoApprovalCriteria(List<Id> requestIds) {     
        //Logic For for auto apprvoal and if criteria is met call an platform event
        
        Map<Id, PRM_Registration_Request__c> acctReqMap = new Map<Id, PRM_Registration_Request__c>(); // atb
        Map<Id,PRM_Registration_Request__c> reqIdMap = new Map<Id,PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> matchedReqs = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> reqToBeUpdated = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> reqToSetAssignedTo = new List<PRM_Registration_Request__c>();
        Set<Id> requests = new Set<Id>();
        String params = '';
        string exceptiondetails = '';
        
        try
        {            
            for(PRM_Registration_Request__c req : [Select ID,PRM_Salesforce_ID__c,PRM_Email_ID__c, PRM_Contact_Salesforce_Id__c, Entitlement_Details__c  
                                                   from PRM_Registration_Request__c where ID =: requestIds])
            {
                acctReqMap.put(req.PRM_Salesforce_ID__c,req); //atb
                reqIdMap.put(req.Id,req);
                params = params + 'Account Id-'+req.PRM_Salesforce_ID__c+';'+' Request ID- '+req.Id+' ;'+' EmailID : '+req.PRM_Email_ID__c + ' ;';
            }
            if(Test.isRunningTest() && reqIdMap.get(requestIds[0]).PRM_Email_ID__c == 'exception@exception.com') {
                throw new CustomException('Exception');
            }
            
            //Retrive Account,ACM and Legal agreement information for auto approval criteria check 
            List<Account> accounts = [SELECT Id,Core_CNDA_Number__c,
                                      (Select PRM_Account_Id__c from Channel_Memberships1__r WHERE PRM_Status_Nm__c = 'Approved' AND
                                       //Added as part of IPA refresh-2025
                                       ((PRM_Partner_Role__c != 'Guest') AND (PRM_Channel_Program_Level_Id__r.Name =: System.Label.PRM_Tier_Partner OR PRM_Channel_Program_Level_Id__r.Name =: System.Label.PRM_Tier_Prestige))),
                                       // ((PRM_Channel_Program_Level_Id__r.Name = 'Gold' OR PRM_Channel_Program_Level_Id__r.Name = 'Titanium') OR (PRM_Channel_Program_Level_Id__r.Name = 'Member' AND PRM_Partner_Role__c = 'Distributor'))),
                                      (SELECT PRM_Account_Id__c FROM AccountLegalAgreementAssociations__r where PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c =: System.Label.PRM_IPATNCCode)
                                      FROM Account WHERE Id= :acctReqMap.keySet()]; //atb
           
            for(Account acct : accounts)
            {           
                //Check if criteria is matched
                if(acct.Channel_Memberships1__r.size() > 0 && (acct.AccountLegalAgreementAssociations__r.size() > 0 || String.isNotBlank(acct.Core_CNDA_Number__c)))
                {
                    
                    matchedReqs.add(acctReqMap.get(acct.id)); //atb
                    PRM_Registration_Request__c req = acctReqMap.get(acct.id);
                    req.Current_Status__c = 'Auto-Approval Pending';
                    req.Assigned_To__c = null;
                    reqToBeUpdated.add(req);                   
                }
            }                  
            if(reqToBeUpdated.size() > 0)
            {       
                    Update reqToBeUpdated;              
            }
            
            //Publish platform event for matched registration request
            List<ProcessAutoApprovedRecords__e> event= new List<ProcessAutoApprovedRecords__e>();
            if(matchedReqs.size() > 0)
            {
                for(PRM_Registration_Request__c req : matchedReqs)
                {
                    ProcessAutoApprovedRecords__e evn= new ProcessAutoApprovedRecords__e();
                    evn.RequestID__c = req.Id;
                    evn.AccountId__c = req.PRM_Salesforce_ID__c;
                    evn.ContactId__c = req.PRM_Contact_Salesforce_Id__c;
                    evn.EntitlementId__c = req.Entitlement_Details__c;
                    event.add(evn);
                    requests.add(req.Id);
                }
            }   
            List<Database.SaveResult> results = EventBus.publish(event);
            ER_ErrorUtility.createLogEntry('Platform Event Sent Request ID- '+requests.toString(),null, LOG_ENTRY_INFO, LOG_ENTRY_SCOPE, 'RequestID- '+requests.toString());
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    params = params +'Request ID- '+matchedReqs[0].Id+' ;';
                    for(Database.Error err : sr.getErrors()) {
                        exceptiondetails += ' Error returned: ' + err.getStatusCode() +' - '+ err.getMessage()+ ' ';
                    }
                }              
            }
            if(string.IsnotBlank(exceptiondetails)){
                throw new CustomException(exceptiondetails);
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
            ER_ErrorUtility.createLogEntry('Error in CheckAutoApprovalCriteria', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }       
    }    
    public class CustomException extends Exception{}
}