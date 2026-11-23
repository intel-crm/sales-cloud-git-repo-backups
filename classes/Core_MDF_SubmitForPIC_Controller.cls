public without sharing class Core_MDF_SubmitForPIC_Controller {
    /*************************************************************************************************************
    Method Name : checkClaimStatusForPICProcess
    @return     : True/False
    @parameters : claimId
    Description : This method is to check on whether the claim status is resubmission required/paid and resubmission required or not
    custom label: Core_MDF_ClaimStatus_For_PICProcess - Resubmission Required;Paid and Resubmission Required
    @Added By:        Accenture - VB - 1-28-2022
	Modified By:        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static Boolean checkClaimStatusForPICProcess(Id claimId){
        Boolean isClaimAvailableForPIC = false;
        List<String> claimStatus = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubmitForPIC_ClaimStatus').split(';');
        PartnerFundClaim pfc = new PartnerFundClaim();
        try {
            pfc = [select Id, Core_MDF_Status__c, Core_MDF_Eligible_for_PIC__c from PartnerFundClaim where Id =: claimId];
            if(claimStatus.contains(pfc.Core_MDF_Status__c) && pfc.Core_MDF_Eligible_for_PIC__c == true) {
                isClaimAvailableForPIC = true;
            } else {
                isClaimAvailableForPIC = false;
            }
            
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());}
        return isClaimAvailableForPIC;
    }

    /*************************************************************************************************************
    Method Name : checkUserAccess
    @return     : True/False
    Description : This method is to check the user with claim submitter permission
    @Added By:        Accenture - VB - 1-28-2022
	Modified By:        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static Boolean checkUserAccess(){
        Boolean isValidUser = false;
        try {
            System.debug('checkUserAccess'+FeatureManagement.checkPermission(Label.Core_MDF_SubmitForPICAccess));
            isValidUser = FeatureManagement.checkPermission(Label.Core_MDF_SubmitForPICAccess);
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());}
        return isValidUser;
    }

    /*************************************************************************************************************
    Method Name : updateClaimStatus
    Description : This method is to update the claim status to PIC Pending/Paid and PIC pending(confirmation popup - submit for PIC)
    @Added By:        Accenture - VB - 2-03-2022
	Modified By:        Date:       Changes: 
    **************************************************************************************************************/
    @AuraEnabled
    public static void updateClaimStatus(Id claimId){
        PartnerFundClaim pfc = new PartnerFundClaim();
        Map<Id, PartnerFundClaim> claimIdToClaimMap = new Map<Id, PartnerFundClaim>();
        try {
            pfc = [select Id, Core_MDF_Status__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Program__c, Core_MDF_OutcomeBased_Ind__c, Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,
                    Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, Core_MDF_Reimbursable_TransactionAmt_Loc__c, Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Currency__c,
                    Core_MDF_Activity_Types__c,Request.Core_MDF_Is_Outcome_Based_Ind__c from PartnerFundClaim where Id =: claimId limit 1];
			//Aditya - PIC status update
			//updated in query and condition
            if(pfc.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Resubmission_Required) {
                pfc.Core_MDF_Status__c = pfc.Request.Core_MDF_Is_Outcome_Based_Ind__c == TRUE ? Label.Core_MDF_Claim_Status_Payment_Clearance_Processing : Label.Core_MDF_Claim_Status_PIC_Pending;
            } 
            else if(pfc.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Paid_and_Resubmission_Required) {
                pfc.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
            } 
            Database.update(pfc);
            
            claimIdToClaimMap.put(claimId, pfc);
            System.debug('pfc.Core_MDF_Status__c'+pfc.Core_MDF_Status__c);
            if(pfc.Core_MDF_Status__c == Label.Core_MDF_Claim_Status_PIC_Pending) {//Add a bypass
                Core_MDF_AI_Integration_Outbound.generateAIResponseForPICProcess(claimIdToClaimMap, 'update');  
            }
        } catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());}
    
    }
}