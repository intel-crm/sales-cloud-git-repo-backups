public with Sharing class ER_ABT_TriggerHandler_Utility {
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_ABT_TriggerHandler_Utility';
    public static boolean ABTSuccess = false;
    
    //Assign Account business type for auto approval process
    public static Map<Id, String> AssignAccountBusinessTypes(List<PRM_Registration_Request__c> reqs, Map<Id,Id> entBusinessTypeMap) 
    {
        List<Account_Business_Types__c> abtToBeInserted = new List<Account_Business_Types__c>();
        Map<Id, String> failedReqIdMap = new Map<Id, String>();
        Map<Id, Id> reqAcctIdMap = new Map<Id, Id>();
        Set<Id> acctIds = new Set<Id>();
        List<PRM_Registration_Request__c> regReqs = new List<PRM_Registration_Request__c>();
        Map<Id,Account_Business_Types__c> abtApprovedMap = new Map<Id,Account_Business_Types__c>();
        String params = '';
        try
        {
            for(PRM_Registration_Request__c req : reqs)
            {
                regReqs.add(req);
                acctIds.add(req.PRM_Salesforce_ID__c);
            }
			//Retrive any existing Account Business type in approved status            
            for(Account_Business_Types__c abt : [SELECT Id,Account__c from Account_Business_Types__c where Account__c IN : acctIds and Business_Types__c IN : entBusinessTypeMap.values() and Status__c = 'Approved'])
            {
                abtApprovedMap.put(abt.Account__c,abt);
            }            
            for (PRM_Registration_Request__c req : regReqs) 
            {
                reqAcctIdMap.put(req.PRM_Salesforce_ID__c,req.Id);
                //Retrive validation to be skipped from metadata
                //ER_skipValidation__mdt skipV = [Select ValidationFields__c from ER_skipValidation__mdt where ProgramCode__c = 'IPA'];
                //Check if ABT is already added in approved status, if yes ignore else add new ABT
                //String skipV=system.label.ER_IPA_Skip_Validation;
                if(abtApprovedMap.get(req.PRM_Salesforce_ID__c) == null)
                {
                    Account_Business_Types__c abt = new Account_Business_Types__c(Account__c = req.PRM_Salesforce_ID__c, 
                                                                                  Business_Types__c = entBusinessTypeMap.get(req.Entitlement_Details__c), 
                                                                                  Status__c = 'Approved',
                                                                                  skipValidation__c = system.label.ER_IPA_Skip_Validation);
                    abtToBeInserted.add(abt);
                }
            }
           
            //if(abtToBeInserted.size() > 0)
            //{
                if(Schema.sObjectType.Account_Business_Types__c.isCreateable() && abtToBeInserted.size() > 0)
                {
                    Database.SaveResult[] srList = Database.insert(abtToBeInserted, false);
                    integer i = 0;
                    string exceptiondetails = '';
                    for (Account_Business_Types__c abt : abtToBeInserted) 
                    {
                        if (!srList[i].isSuccess()) 
                        {
                            failedReqIdMap.put(reqAcctIdMap.get(abt.Account__c),srList[i].getErrors().get(0).getMessage());
                            params = params + 'Account Id-'+abt.Account__c+';'+' Request ID- '+reqAcctIdMap.get(abt.Account__c)+' ;';
                            exceptiondetails = exceptiondetails + ' Request ID- '+reqAcctIdMap.get(abt.Account__c) + ' : '+srList[i].getErrors().get(0).getMessage() +' ;';
                        }
                        i++;
                    }
                    if(failedReqIdMap.size() > 0)
                    {
                        throw new CustomException(exceptiondetails);
                    }
                }
				else if((!Schema.sObjectType.Account_Business_Types__c.isCreateable()) && abtToBeInserted.size() > 0)
				{
					for (Account_Business_Types__c abt : abtToBeInserted) 
					{
						failedReqIdMap.put(reqAcctIdMap.get(abt.Account__c),'ABT insertion failed due to insufficient access');
					}
				}
            //}
        }
        catch(Exception ex)
        {
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in AssignAccountBusinessTypes', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
        return failedReqIdMap;
    }
    
    //Reject CBTs if ABT status is changed to Rejected
    public static void RejectCBTStatus(List<Account_Business_Types__c> newList, Map<Id, Account_Business_Types__c> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> businessTypeIds = new Set<Id>();
        Map<Id, List<Contact_Business_Types__c>> acctCbts = new Map<Id, List<Contact_Business_Types__c>>();
        List<Contact_Business_Types__c> cbtsToUpdate = new List<Contact_Business_Types__c>();
        String params = '';
        try {
            //Retrive account Ids and business type ids from abt
            for (Account_Business_Types__c abt : newList){
                accountIds.add(abt.Account__c);
                businessTypeIds.add(abt.Business_Types__c);
            } 
            //Retrive all approved CBTs for that particular accounts and business types and form map
            for(Contact_Business_Types__c cbt : [SELECT id, Contact__c, Contact__r.Email, Business_Types__c, Business_Types__r.Name, 
                                                 Status__c, Contact__r.AccountId
                                                 FROM Contact_Business_Types__c 
                                                 WHERE Business_Types__c IN :businessTypeIds AND Contact__r.AccountId In : accountIds 
                                                 AND Status__c = 'Approved'])
            {
                if(acctCbts.ContainsKey(cbt.Contact__r.AccountId)) {
                    List<Contact_Business_Types__c> cbts = acctCbts.get(cbt.Contact__r.AccountId);
                    cbts.add(cbt);
                    acctCbts.put(cbt.Contact__r.AccountId, cbts);
                }
                else {
                    acctCbts.put(cbt.Contact__r.AccountId, new List<Contact_Business_Types__c>{cbt});
                }
            }
            
            //Loop through ABTs
            //Retrive all CBTs for account in ABT and update CBT status to Rejection - Pending
            //Update only if ABT status is changing from Approved to Rejected
            for (Account_Business_Types__c abt : newList){
                Account_Business_Types__c oldABT = oldMap.get(abt.Id);
                params = params + 'Account Business Type Id-'+abt.Id+';';
                if(oldABT != null && oldABT.Status__c == 'Approved' && abt.Status__c == 'Rejected' && acctCbts.ContainsKey(abt.Account__c)) {
                    for(Contact_Business_Types__c cbt : acctCbts.get(abt.Account__c)) {
                        cbt.Status__c = 'Rejection - Pending';
                        cbtsToUpdate.add(cbt);
                    }
                }
                if(Test.isRunningTest() && abt.Status_Reason__c == 'exception') {
                    throw new ER_ErrorUtility.CustomException('exception');
                }
            }
            //if(cbtsToUpdate.size() > 0){
                if(Schema.sObjectType.Contact_Business_Types__c.isUpdateable() && cbtsToUpdate.size() > 0){
                    update cbtsToUpdate;
                }
                
            //}
            
        }
        catch(Exception ex) {
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ex.getMessage();
            custEx.Cause = ex.getCause();
            custEx.StackTraceString = ex.getStackTraceString();
            custEx.LineNumber = ex.getLineNumber();                
            custEx.TypeName = ex.getTypeName();            
            ER_ErrorUtility.createLogEntry('Error in RejectCBTStatus', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
        }
    }
    public class CustomException extends Exception{}
}