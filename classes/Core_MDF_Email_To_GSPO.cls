public class Core_MDF_Email_To_GSPO {
@InvocableMethod
    Public static List<Boolean> sendEmailToGSPO(List<Id> paymentRunId){
            Id paymentRunIdToBatchClass = paymentRunId[0];
          List<Boolean> booleanList = new List<Boolean>();
      List<Core_MDF_Claim_VAT_Info__c> vatInformationRecs = new list<Core_MDF_Claim_VAT_Info__c>();
      vatInformationRecs = [Select Id, Core_MDF_Approved_File_Name_Txt__c from Core_MDF_Claim_VAT_Info__c where 
							 Core_MDF_Claim_Id__r.Core_MDF_Payment_Id__r.Core_MDF_Payment_Run_Id__c =: 		
							 paymentRunIdToBatchClass AND Core_MDF_Claim_Id__r.Core_MDF_VAT_Eligibility_Ind__c = true];
        // call Batch Class
        if(!vatInformationRecs.isEmpty()){
       Core_MDF_Batch_SendEmailToGSPO sendemailgspo = new Core_MDF_Batch_SendEmailToGSPO(vatInformationRecs);
       Database.executeBatch(sendemailgspo,200);
        system.debug('@@ After batch class');
            booleanList.add(true);
            return booleanList;
        }
        else{
              booleanList.add(false);
            return booleanList;
        }
      }
}