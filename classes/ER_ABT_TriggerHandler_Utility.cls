public with Sharing class ER_ABT_TriggerHandler_Utility {
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_ABT_TriggerHandler_Utility';
    public static boolean ABTSuccess = false;
    
    // TWC722-178 Commented, because standard validations rules are implemented
    //Validations for ABT
    /* public static void ABTValidations(List<Account_Business_Types__c> newList) {
Set<Id> accountIds = new Set<Id>();
String params = '';
try{
for (Account_Business_Types__c abt : newList) {
accountIds.add(abt.Account__c);
}            
Map<Id, Account> acctsMap = new Map<Id, Account>([SELECT Id, Core_English_Only_Name__c, OwnerId, Core_CNDA_Number__c, 
Core_CIM_ID__c, Core_Covered_Account__c,Owner.UserRoleId
FROM Account WHERE Id in : accountIds]);             

for (Account_Business_Types__c abt : newList) {
Account acct = acctsMap.get(abt.Account__c);
params = params + 'Account Business Type Id-'+abt.Id+'- AccountID-'+acct.Id+';';
if(String.isBlank(acct.Core_English_Only_Name__c)) {
abt.addError(Label.ABT_Eng_Account_Name_Check);
}
if(String.isBlank(acct.Owner.UserRoleId)) {
abt.addError(Label.ABT_Account_Owner_Role_Check);
}
if(String.isBlank(acct.Core_CNDA_Number__c)) {
abt.addError(Label.ABT_CNDA_Check);
}
if(String.isBlank(acct.Core_CIM_ID__c)) {
abt.addError(Label.ABT_Account_CIM_Check);
}
if(!acct.Core_Covered_Account__c) {
abt.addError(Label.ABT_Covered_Account_Check);
}
if(Test.isRunningTest() && acct.Core_English_Only_Name__c == 'exception'){
throw new ER_ErrorUtility.CustomException('exception');
}
}                                
}
catch(Exception ex) {
ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
custEx.Message = ex.getMessage();
custEx.Cause = ex.getCause();
custEx.StackTraceString = ex.getStackTraceString();
custEx.LineNumber = ex.getLineNumber();                
custEx.TypeName = ex.getTypeName();            
ER_ErrorUtility.createLogEntry('Error in ABTValidations', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, params);
}
} */
    
    public static Map<Id, String> AssignAccountBusinessTypes(List<Id> reqIds) 
    {
        List<Account_Business_Types__c> abtToBeInserted = new List<Account_Business_Types__c>();
        Map<Id, String> failedReqIdMap = new Map<Id, String>();
        Map<Id, Id> reqAcctIdMap = new Map<Id, Id>();
        Set<Id> entIds = new Set<Id>();
        Set<Id> acctIds = new Set<Id>();
        List<PRM_Registration_Request__c> regReqs = new List<PRM_Registration_Request__c>();
        Map<Id,Id> entBusinessTypeMap = new Map<Id,Id>();
        Map<Id,Account_Business_Types__c> abtApprovedMap = new Map<Id,Account_Business_Types__c>();
        String params = '';
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        try
        {
        for(PRM_Registration_Request__c req : [Select ID,PRM_Salesforce_ID__c,Entitlement_Details__c from PRM_Registration_Request__c where ID =: reqIds])
        {
            entIds.add(req.Entitlement_Details__c);
            regReqs.add(req);
            acctIds.add(req.PRM_Salesforce_ID__c);
        }
        for(PRM_VXEnttlmntMatrix__c mat : [SELECT Business_Types__c,PRM_Entitlement_Id__c FROM PRM_VXEnttlmntMatrix__c WHERE PRM_Entitlement_Id__c IN : entIds and RecordTypeId=: eBREnttRecTypeId])
        {
            entBusinessTypeMap.put(mat.PRM_Entitlement_Id__c,mat.Business_Types__c);
        }
        
       for(Account_Business_Types__c abt : [SELECT Id,Account__c from Account_Business_Types__c where Account__c IN : acctIds and Business_Types__c IN : entBusinessTypeMap.values() and Status__c = 'Approved'])
       {
           abtApprovedMap.put(abt.Account__c,abt);
       }
        
        for (PRM_Registration_Request__c req : regReqs) 
        {
            reqAcctIdMap.put(req.PRM_Salesforce_ID__c,req.Id);
            ER_skipValidation__mdt skipV = [Select ValidationFields__c from ER_skipValidation__mdt where ProgramCode__c = 'IPA'];
            if(abtApprovedMap.get(req.PRM_Salesforce_ID__c) == null)
            {
                Account_Business_Types__c abt = new Account_Business_Types__c(Account__c = req.PRM_Salesforce_ID__c, 
                                                                              Business_Types__c = entBusinessTypeMap.get(req.Entitlement_Details__c), 
                                                                              Status__c = 'Approved',
                                                                              skipValidation__c = skipV.ValidationFields__c);
                abtToBeInserted.add(abt);
            }
        }
        System.debug('abtToBeInserted'+abtToBeInserted);
        System.debug('reqAcctIdMap '+reqAcctIdMap);
        
        if(abtToBeInserted.size() > 0)
        {
            if(Schema.sObjectType.Account_Business_Types__c.isCreateable())
            {
                System.debug('Insert Success'+abtToBeInserted);
                Database.SaveResult[] srList = Database.insert(abtToBeInserted, false);
                integer i = 0;
                string exceptiondetails = '';
                for (Account_Business_Types__c abt : abtToBeInserted) 
                {
                    System.debug('abt : '+abt);
                    if (!srList[i].isSuccess()) 
                    {
                        failedReqIdMap.put(reqAcctIdMap.get(abt.Account__c),srList[i].getErrors().get(0).getMessage());
                        System.debug('sr : '+srList[i].getErrors());
                        params = params + 'Account Id-'+abt.Account__c+';'+' Request ID- '+reqAcctIdMap.get(abt.Account__c)+' ;';
                        exceptiondetails = exceptiondetails + ' Request ID- '+reqAcctIdMap.get(abt.Account__c) + ' : '+srList[i].getErrors().get(0).getMessage() +' ;';
                    }
                    i++;
                }
                System.debug('failedReqIdMap : '+failedReqIdMap);
                if(failedReqIdMap.size() > 0)
                {
                    throw new CustomException(exceptiondetails);
                }
                //list of accountids<id,string> abtsfailed with error message
                    System.debug('Insert Success 2'+abtToBeInserted);
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
            if(cbtsToUpdate.size() > 0){
                if(Schema.sObjectType.Contact_Business_Types__c.isUpdateable()){
                    update cbtsToUpdate;
                }
                
            }
            
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