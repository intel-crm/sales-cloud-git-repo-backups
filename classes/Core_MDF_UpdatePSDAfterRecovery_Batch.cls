public class Core_MDF_UpdatePSDAfterRecovery_Batch implements Database.Batchable<sObject>{
	public List<Core_MDF_Recovery_Request__c> recoveryReqList = new List<Core_MDF_Recovery_Request__c>();

   public Core_MDF_UpdatePSDAfterRecovery_Batch(List<Core_MDF_Recovery_Request__c> finalRecoveryReqList){
		recoveryReqList = finalRecoveryReqList;
   }

   public Iterable<Core_MDF_Recovery_Request__c> start(Database.BatchableContext bc){
      return recoveryReqList;
   }

   public void execute(Database.BatchableContext bc, List<Core_MDF_Recovery_Request__c> recoveryReqList){
     Core_MDF_Recovery_Utility.updatePartnershipScoreDetailMapping(recoveryReqList);
    }

   public void finish(Database.BatchableContext bc){
   }

}