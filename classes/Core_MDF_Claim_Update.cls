/*public class Core_MDF_Claim_Update {

}*/
/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_Claim_Update 
* Version     : 1.0 
* Created Date: 10-03-2019
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - Ealisha 		10-03-2019					  Scheduler class to invoke Core_MDF_Batch_RetryCaseCreation
**************************************************************************************************************************************************************************************/
global without sharing class Core_MDF_Claim_Update{
    global static void updateClaim(List<PartnerFundClaim> pfcList) {  
        //get all claim ids from auditHoldClaim object which got created 1 hr before the batch run. 
        
        //and Createddate <=: todaysDate  
        //   
        /*String query=
'select Id,Name,Core_MDF_Retry_Indicator__c,Core_MDF_Hold_Claim__c,Core_MDF_Status__c,Core_MDF_Claim_Id__c,Createddate from Core_MDF_Audit_Hold_Claim__c where Core_MDF_Status__c in(\'Pending\') and Core_MDF_Hold_Claim__c in(\'UpdateClaim\')';
System.debug('query:'+query); */
        Set<Id> pfcIdSet = new Set<Id>();
        for(PartnerFundClaim pfc : pfcList){
            pfcIdSet.add(pfc.Id);  
        }
        
        String query = 'SELECT id,Core_MDF_Audit_Type__c,Core_MDF_FlaggedForAudit__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c FROM PartnerFundClaim WHERE Id IN : pfcId';
        Core_MDF_Batch_ClaimUpdate caseCreationRetryBatch = new Core_MDF_Batch_ClaimUpdate();
        //caseCreationRetryBatch.queryActive = query;
        caseCreationRetryBatch.pfcIdSet = pfcIdSet;

        
        Database.executeBatch(caseCreationRetryBatch, 20);
    }
}