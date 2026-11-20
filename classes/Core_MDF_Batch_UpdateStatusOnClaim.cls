/**********************************************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_UpdateStatusOnClaim
* Version     : 1.0 
* Created Date: 10 MAR-2021
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture- Bishal         		10-MAR-2021                  Batch Class to release bank document hold from claim
***********************************************************************************************************************************************************************/


public class Core_MDF_Batch_UpdateStatusOnClaim implements Database.Batchable<sObject>{
        List<Id> selClaimIdList = new List<Id>();
        // Incoming List of CLaims for which Bank Document Hold To be Released
        public Core_MDF_Batch_UpdateStatusOnClaim(List<ID> selClaimIdList) {
            this.selClaimIdList = selClaimIdList;
        }
        
        public Database.QueryLocator start(Database.BatchableContext bc) {
            String query = 'select id, Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Audit_Hold__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Document_Hold_Ind__c, Core_MDF_Status__c, Core_MDF_Claim_Previous_Status__c from PartnerFundClaim where Core_MDF_Bank_Doc_Hold_Ind__c = true and Core_MDF_Audit_Hold__c = false and Core_MDF_Status__c = \'hold\' and id in:selClaimIdList';
            return Database.getQueryLocator(query);
        }
        
          public void execute(Database.BatchableContext bc, List<PartnerFundClaim> claimsList) {
              
              
              List<String> releaseReasonList = new List<String>();
              //Added the bank document hold string to pass to the releaseHold method
              releaseReasonList.add(Label.Core_MDF_Bank_Document_Hold);
              //system.debug('@@@ claimlist'+claimsList);
              if(releaseReasonList!=NULL && releaseReasonList.size() > 0){
                  //calling the release hold method for updating the bank document to false and changing the status of the claim.
               Core_MDF_Claim_Utility.releaseHold(claimsList, releaseReasonList); 
            }
          }
         public void finish(Database.BatchableContext bc){}
    }