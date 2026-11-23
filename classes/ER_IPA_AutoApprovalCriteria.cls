public class ER_IPA_AutoApprovalCriteria {
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_IPA_AutoApprovalCriteria';
    
    @InvocableMethod(label='IPA Auto Approval Check' description='Check for IPA Auto Approvals for EBR' category= 'New Registration')
    public static List<Id> CheckIPAAutoApprovalCriteria(List<Id> requestIds) {     
        //Logic For for auto apprvoal and if criteria is met call an platform event
        
        Boolean isAutoApprovalCriteriaMet = false;
        Map<Id, Id> reqAcctIdMap = new Map<Id, Id>();
        Map<Id,PRM_Registration_Request__c> reqIdMap = new Map<Id,PRM_Registration_Request__c>();
        List<Id> matchedReqId = new List<Id>();
        List<PRM_Registration_Request__c> reqToBeUpdated = new List<PRM_Registration_Request__c>();
        List<PRM_Registration_Request__c> reqToSetAssignedTo = new List<PRM_Registration_Request__c>();
        String params = '';
        
        try
        {
            
            for(PRM_Registration_Request__c req : [Select ID,Account_ID__c,PRM_Email_ID__c from PRM_Registration_Request__c where ID =: requestIds])
            {
                //reqAcctIdMap.put(req.Id,req.Account_ID__c);
                reqAcctIdMap.put(req.Account_ID__c,req.Id);
                reqIdMap.put(req.Id,req);
                params = params + 'Account Id-'+req.Account_ID__c+';'+' Request ID- '+req.Id+' ;'+' EmailID : '+req.PRM_Email_ID__c + ' ;';
                System.debug('reqAcctIdMap'+reqAcctIdMap);
                System.debug('reqIdMap size'+reqIdMap.size());
            }
            
            List<Account> accounts = [SELECT Id,Core_CNDA_Number__c,
                                      (Select PRM_Account_Id__c from Channel_Memberships1__r WHERE ((PRM_Channel_Program_Level_Id__r.Name = 'Gold' OR PRM_Channel_Program_Level_Id__r.Name = 'Titanium') OR (PRM_Channel_Program_Level_Id__r.Name = 'Member' AND PRM_Partner_Role__c = 'Distributor'))),
                                      (SELECT PRM_Account_Id__c FROM AccountLegalAgreementAssociations__r where PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c =: System.Label.PRM_IPATNCCode)
                                      FROM Account WHERE Id= :reqAcctIdMap.keySet()];
            System.debug(accounts);
            
            for(Account acct : accounts)
            {
                if(acct.Channel_Memberships1__r.size() > 0 && (acct.AccountLegalAgreementAssociations__r.size() > 0 || String.isNotBlank(acct.Core_CNDA_Number__c)))
                {
                    System.debug(acct.id);
                    matchedReqId.add(reqAcctIdMap.get(acct.id));                  
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
                if(Schema.sObjectType.PRM_Registration_Request__c.isUpdateable())
                {
                    System.debug('Update Success'+reqToBeUpdated);
                    Update reqToBeUpdated;
                    System.debug('Update Success 2'+reqToBeUpdated);
                }
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
        return matchedReqId;
        
    }
    
    public class CustomException extends Exception{}

}