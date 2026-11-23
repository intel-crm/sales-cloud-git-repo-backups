public class ER_CheckAutoapprovalCriteria 
{
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_CheckAutoapprovalCriteria';
    
    @InvocableMethod(label='Auto Approval Check' description='Check for Auto Approvals for EBR' category= 'New Registration')
    public static void CheckAutoApprovalCriteria(List<Id> requestIds) {     
        //Logic For for auto apprvoal and if criteria is met call an platform event
        
        Map<Id, Id> reqAcctIdMap = new Map<Id, Id>();
        Map<Id,PRM_Registration_Request__c> reqIdMap = new Map<Id,PRM_Registration_Request__c>();
        List<Id> matchedReqId = new List<Id>();
        List<PRM_Registration_Request__c> reqToBeUpdated = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> reqToSetAssignedTo = new List<PRM_Registration_Request__c>();
        String params = '';
        string exceptiondetails = '';
        
        try
        {
            
            for(PRM_Registration_Request__c req : [Select ID,PRM_Salesforce_ID__c,PRM_Email_ID__c from PRM_Registration_Request__c where ID =: requestIds])
            {
                //reqAcctIdMap.put(req.Id,req.PRM_Salesforce_ID__c);
                reqAcctIdMap.put(req.PRM_Salesforce_ID__c,req.Id);
                reqIdMap.put(req.Id,req);
                params = params + 'Account Id-'+req.PRM_Salesforce_ID__c+';'+' Request ID- '+req.Id+' ;'+' EmailID : '+req.PRM_Email_ID__c + ' ;';
                System.debug('reqAcctIdMap'+reqAcctIdMap);
                System.debug('reqIdMap size'+reqIdMap.size());
            }
            
            List<Account> accounts = [SELECT Id,Core_CNDA_Number__c,
                                      (Select PRM_Account_Id__c from Channel_Memberships1__r WHERE PRM_Status_Nm__c = 'Approved' AND
                                       //Added as part of IPA refresh-2025
                                       ((PRM_Partner_Role__c != 'Guest') AND (PRM_Channel_Program_Level_Id__r.Name =: System.Label.PRM_Tier_Partner OR PRM_Channel_Program_Level_Id__r.Name =: System.Label.PRM_Tier_Prestige))),
                                       // ((PRM_Channel_Program_Level_Id__r.Name = 'Gold' OR PRM_Channel_Program_Level_Id__r.Name = 'Titanium') OR (PRM_Channel_Program_Level_Id__r.Name = 'Member' AND PRM_Partner_Role__c = 'Distributor'))),
                                      (SELECT PRM_Account_Id__c FROM AccountLegalAgreementAssociations__r where PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c =: System.Label.PRM_IPATNCCode)
                                      FROM Account WHERE Id= :reqAcctIdMap.keySet()];
            System.debug(accounts);
            
            for(Account acct : accounts)
            {
                if(acct.Channel_Memberships1__r.size() > 0 && (acct.AccountLegalAgreementAssociations__r.size() > 0 || String.isNotBlank(acct.Core_CNDA_Number__c)))
                {
                    System.debug(acct.id);
                    matchedReqId.add(reqAcctIdMap.get(acct.id));
                    PRM_Registration_Request__c req = reqIdMap.get(reqAcctIdMap.get(acct.id));
                    req.Current_Status__c = 'Auto-Approval Pending';
                    reqToBeUpdated.add(req);
                    
                }   
                else
                {
                    reqToSetAssignedTo.add(reqIdMap.get(reqAcctIdMap.get(acct.id)));
                }
            }
            
            if(reqToSetAssignedTo != null && reqToSetAssignedTo.size() > 0)
            {
                ER_RegistrationUtility.setAssignedTo(reqToSetAssignedTo);
                reqToBeUpdated.addall(reqToSetAssignedTo);
            }        
            
            if(reqToBeUpdated.size() > 0)
            {
                System.debug('Update Success'+reqToBeUpdated);
                Update reqToBeUpdated;
                System.debug('Update Success 2'+reqToBeUpdated);
            }
            
            List<ProcessAutoApprovedRecords__e> event= new List<ProcessAutoApprovedRecords__e>();
            if(matchedReqId.size() > 0)
            {
                for(Id reqid : matchedReqId)
                {
                    ProcessAutoApprovedRecords__e evn= new ProcessAutoApprovedRecords__e();
                    evn.RequestID__c = reqid;
                    event.add(evn);
                    ER_ErrorUtility.createLogEntry('Platform Event Sent Request ID- '+reqid,null, LOG_ENTRY_INFO, LOG_ENTRY_SCOPE, 'RequestID- '+reqid);
                }
            }
            System.debug('Before Platform event publish');
            List<Database.SaveResult> results = EventBus.publish(event);
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    params = params +'Request ID- '+matchedReqId[0]+' ;';
                    for(Database.Error err : sr.getErrors()) {
                        exceptiondetails += ' Error returned: ' + err.getStatusCode() +' - '+ err.getMessage()+ ' ';
                    }
                }
                
                System.debug('results'+results);
            }
            if(exceptiondetails !=null){
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