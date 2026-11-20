/**********************************************************************************************************************************************************************
* Class Name  : Core_MDF_Bulk_ReleaseBankDocHold
* Version     : 1.0 
* Created Date: 1MAR-2021
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture- Hamza         		1-MAR-2021                         Check if User is having access to the bulk release hold tab and release the claims from hold
***********************************************************************************************************************************************************************/

public with sharing class Core_MDF_Bulk_ReleaseBankDocHold {
    /*****************************************************************************************************
     Method Name:        getClaims
     @return  :          List
     @parameters:        
     Description:          Pass the claim from apex to display in LWC lightning Data Table
     @Added By:          Accenture - Hamza - 01/03/2021
     Modified By:        Date:       Changes:
     ******************************************************************************************************/
   @AuraEnabled(cacheable=true)
   //fetch claims on bank document hold and audit hold is false
    public static List<PartnerFundClaim> getClaims(){
        return [Select id, Title, Amount, Core_MDF_Bank_Doc_Hold_Ind__c, Core_MDF_Claim_Ref_Number__c, Core_MDF_AccountCompany__c, Core_MDF_Program__c, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_Budget_Type_Options_Nm__c
        From PartnerFundClaim Where Core_MDF_Bank_Doc_Hold_Ind__c = true and Core_MDF_Audit_Hold__c = false and Core_MDF_Status__c = 'Hold'];
    }
    
      /*****************************************************************************************************
     Method Name:        checkAccess
     @return  :          Boolean
     @parameters:        
     Description:        checking user access whether the user is having the correct perimssion to release bank document hold
     @Added By:          Accenture - Hamza - 01/03/2021
     Modified By:        Date:       Changes:
     ******************************************************************************************************/
    
    @AuraEnabled
    public static Boolean checkAccess(){
        Boolean hasAccessForBankDocumentHold = FeatureManagement.checkPermission(Label.Core_MDF_Permission_To_Release_Bank_Document_Hold);
        return hasAccessForBankDocumentHold;        
    }
    
     /*****************************************************************************************************
     Method Name:        releaseHold
     @return  :          String
     @parameters:        List<Id>
     Description:        Bulk Release Hold logic called on click of Release Hold button, batch class getting called from here if record is more than 30 otherwise normal processing
     @Added By:          Accenture - Hamza - 01/03/2021
     Modified By:        Date:       Changes:
     ******************************************************************************************************/
    
    //Bulk Release Hold logic called on click of Release Hold button, batch class getting called from here
    @AuraEnabled
    public static String releaseHold(List<Id> selClaimIdList){
        
        String messageDisplayOnComponent = '';
        if(selClaimIdList!=null && selClaimIdList.size()>0){
            // Get the exact size of the selected claim which is passed from LWC
            Integer  querySize = selClaimIdList.size();
       
            
            Integer queryLimit = Integer.ValueOf(Core_MDF_Configuration__c.getValues('BATCH_RECORD_LIMIT_FOR_BULKRELEASE').Core_MDF_Value__c);//Get limit of claim records
            if(querySize <= queryLimit){
                // call the below method if query size is less than equal to 30 to process the record instantly
                immediateReleaseBankDocHold(selClaimIdList); 
                messageDisplayOnComponent = Label.Core_MDF_ImmediateReleaseBankDoCHoldMessage;
              
            }
            else{
			
			//call the batch class if querysize is more than 30
            Core_MDF_Batch_UpdateStatusOnClaim releaseHoldBatchClass = new Core_MDF_Batch_UpdateStatusOnClaim(selClaimIdList);
            database.executebatch(releaseHoldBatchClass,queryLimit);
                messageDisplayOnComponent = Label.Core_MDF_BatchReleaseHoldMessgae;
               
                }
    }
        return messageDisplayOnComponent;
}

/*****************************************************************************************************
     Method Name:        immediateReleaseBankDocHold
     @return  :          void
     @parameters:        List<Id>
     Description:        Bulk Release Hold logic called on click of Release Hold button,if record is less than or equal to 30 for normal processing
     @Added By:          Accenture - Bishal - 15/03/2021
     Modified By:        Date:       Changes:
     RP                  Added Core_MDF_Has_Sub_Claims_Ind__c
     ******************************************************************************************************/

    public static void immediateReleaseBankDocHold(List<Id> claimIds){
        
                   List<PartnerFundClaim> claimsToReleaseBankDocHold = new List<PartnerFundClaim>();
				   claimsToReleaseBankDocHold = [select id, Core_MDF_Bank_Doc_Hold_Ind__c,Core_MDF_Audit_Hold__c,Core_MDF_ESD_Hold__c,Core_MDF_Payment_Hold_ind__c,Core_MDF_Intel_Manual_Hold_Ind__c,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_VAT_Hold_Ind__c,Core_MDF_Document_Hold_Ind__c,Core_MDF_Criteria_Hold_Ind__c, Core_MDF_Status__c, Core_MDF_Claim_Previous_Status__c, Core_MDF_Has_Sub_Claims_Ind__c from PartnerFundClaim where Core_MDF_Bank_Doc_Hold_Ind__c = true and Core_MDF_Audit_Hold__c = false and Core_MDF_Status__c = 'Hold' and id in:claimIds];
				   List<String> releaseReasonList = new List<String>();
              //Added the bank document hold string to pass to the releaseHold method
              releaseReasonList.add(Label.Core_MDF_Bank_Document_Hold);
           
              if(releaseReasonList!=NULL && releaseReasonList.size() > 0){
                  //calling the release hold method for updating the bank document to false and changing the status of the claim.
               Core_MDF_Claim_Utility.releaseHold(claimsToReleaseBankDocHold, releaseReasonList); 
    }
}
}