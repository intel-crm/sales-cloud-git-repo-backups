public without sharing class Core_MDF_PIC_Utility {

    
/**
* @description : Method to check the claim's PIC is completed
* @param newclaim : new claims (updated) 
* @param oldClaim : claims (not updated) 
*/ 
    
    public static List<PartnerFundClaim> vatClaims = new List<PartnerFundClaim>();
    
    public static Boolean isPICCompleted(PartnerFundClaim newclaim,PartnerFundClaim oldClaim){
        
          if(oldClaim !=null && (newclaim.Core_MDF_PIC_Review_Completed__c && !oldClaim.Core_MDF_PIC_Review_Completed__c))// && newclaim.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PIC_Pending')
                  { 
                       return true;
                   }else{ return false;} 
            
        }
    public static void checkForHoldIndAndUpdateStatus(Map<Id, PartnerFundClaim> newClaimMap, Map<Id,PartnerFundClaim> oldClaimMap)
    {
        List<String> listOfInvalidStatusForHoldCheckOnUpdate = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_ClaimStatusExcludedForHoldCheck');
        List<string> opalBudgetTypes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').split(';');

        String claimStatusPaid = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Paid'); //Paid
        String claimStatusPendingPayment = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Payment'); //Pending Payment
        String rowCauseManual = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RowCause_Manual');
        
        //To check the documents are uploaded for a Claim
        Map<Id,Boolean> claimIdToDocuemntStatusMap = Core_MDF_Audit_Rules_Processing.checkPOPDocuments(new List<Id>(newClaimMap.keySet()));

        for(PartnerFundClaim newclaim : newClaimMap.values())
        {
           
            
            if(isLegacy(newclaim) && !newclaim.Core_MDF_Eligible_for_PIC__c)
            {
                //excluding final statuses in hold check
                if(listOfInvalidStatusForHoldCheckOnUpdate!=null && !listOfInvalidStatusForHoldCheckOnUpdate.contains(newclaim.Core_MDF_Status__c) && isHoldApplicable(newclaim))
                {
                    newclaim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold');
                    if(newclaim.Core_MDF_Reprocess_Claim__c == true)
                    {
                        newclaim.Core_MDF_Reprocess_Claim__c = false;
                    }
                    //Added to uncheck reprocess claim checkbox to avoid conflict with validation rule
                }
            }

            // Roshan - added program check for cogtm
            else if(newClaim.Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM && newclaim.Core_MDF_Eligible_for_PIC__c && isPICCompleted(newclaim, oldClaimMap.get(newclaim.id)) && isHoldApplicable(newclaim)) {
                newclaim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold');
            }
            else if(newClaim.Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM && newclaim.Core_MDF_Eligible_for_PIC__c && isPICCompleted(newclaim, oldClaimMap.get(newclaim.id)) && !isHoldApplicable(newclaim) && newclaim.Core_MDF_Status__c != 'Paid') {
                newclaim.Core_MDF_Status__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted');
            }
            else if(newClaim.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM && newclaim.Core_MDF_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted') && oldClaimMap.get(newclaim.id).Core_MDF_Status__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold'))
                
            {
            	newclaim.Core_MDF_Status__c = isHoldApplicable(newclaim) ? Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Hold') : Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Submitted');
                
            }

            //Related to Manual Audit
            //Once Legacy claim status updated to Paid from Pending Payment and if the Manaul Audit Staging flag is true
            if(newClaim.Core_MDF_Legacy_Claim_Ind__c && !newClaim.Core_MDF_PIC_review_completed__c&& newclaim.Core_MDF_Manaul_Audit_Staging_Ind__c 
                && newclaim.Core_MDF_Status__c != oldClaimMap.get(newclaim.id).Core_MDF_Status__c
                && oldClaimMap.get(newclaim.id).Core_MDF_Status__c == claimStatusPendingPayment && newclaim.Core_MDF_Status__c == claimStatusPaid){

                if(!claimIdToDocuemntStatusMap.get(newclaim.Id)){
                    newclaim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_Pending_Documents;
                    newclaim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = System.now() + Integer.valueOf(Label.Core_MDF_Document_Submission_Days);//For Reminder Notifications
                }else{
                    newclaim.Core_MDF_Status__c = Label.Core_MDF_Claim_Status_Paid_and_PIC_Pending;
                    newclaim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c = null;
                }
            }

            //Related to Manual Audit
            //When Legacy claim status updated to Paid after PIC Completion(Post Payment))
            if(newClaim.Core_MDF_Legacy_Claim_Ind__c && isPICCompleted(newclaim, oldClaimMap.get(newclaim.id)) && newclaim.Core_MDF_Manaul_Audit_Staging_Ind__c
                && oldClaimMap.get(newclaim.id).Core_MDF_Status__c == Label.Core_MDF_Claim_Status_Paid_and_PIC_Pending && newclaim.Core_MDF_Status__c == claimStatusPaid){

                newclaim.Core_MDF_Manaul_Audit_Staging_Ind__c = false;
                newclaim.Core_MDF_Audit_Hold__c = true;
                newclaim.Core_MDF_FlaggedForAudit__c = true;
                newclaim.Core_MDF_Audit_Type__c = rowCauseManual;
            }
        }
        if(vatClaims != null && vatClaims.size()>0){
            Core_MDF_Claim_VAT_Process.updateclaimVATInfo(vatClaims);
        }
    }
    
    public static boolean isHoldApplicable(PartnerFundClaim newclaim)
    {
        boolean isHold = false;
		if(newclaim.Core_MDF_ESD_Hold__c || newclaim.Core_MDF_Payment_Hold_ind__c || newclaim.Core_MDF_Criteria_Hold_Ind__c || newClaim.Core_MDF_Member_Manual_Hold_Ind__c || newClaim.Core_MDF_Intel_Manual_Hold_Ind__c)
        {
            isHold = true;
        }
        if(newclaim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c){
            newClaim.Core_MDF_Bank_Doc_Hold_Ind__c = true;
            isHold = true;   
        }
        if(newclaim.Core_MDF_VAT_Eligibility_Ind__c){
            //adding eligible claims to this list which will be used to call Core_MDF_Claim_VAT_Process.updateclaimVATInfo
            //where Core_MDF_VAT_Hold_Ind__c = true and status will be updated to hold based on the amount checks
            vatClaims.add(newclaim);   
        }
       
        return isHold;
    }
    
    
    public static boolean isLegacy(PartnerFundClaim claim)
    {
        if(((claim.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCF_Program_Name') || claim.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DCF_Program_Name'))
           && (claim.Core_MDF_Budget_Type_Options_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_CCF1_0') || claim.Core_MDF_Budget_Type_Options_Nm__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetType_DCF1_0')))
          || claim.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Program_Name') || claim.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCFB_Program_Name'))
        {
           
            return true;
        }
        else
            return false;   
    }
    
    public static void addDelay()
    {
        Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('Core_MDF_SecondsToDelayPICBatch');  
        DateTime start = System.now();
        while(System.now() < start.addSeconds(Integer.valueOf(config.Core_MDF_Value__c))){}
    }
}