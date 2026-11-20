/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_ESDHoldCheck  
* Version     : 1.0  
* Created Date: 11-12-2018 
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – AD        11/12/2018                    Created Core_MDF_PFC_ESDHoldCheck for update claim status      
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PFC_HoldCheck{
    
    //public static Map<string,string> bankIdVatPercent = new Map<string,string>();
    public static Map<Id,Core_MDF_Bank__c> bankIdTobankInstance = new Map<Id,Core_MDF_Bank__c>();
    
    /****************************************************************************************************** 
    Method Name:        checkESDHoldAndUpdateClaimStatusInsert
    @return  :          N/A
    @parameters:        List<PartnerFundClaim> object
    Description:        This method is called from claim trigger and used to update claim status,
    if claim bank status is 'Hold'
    Added By:           Accenture - AD - 11/12/2018
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void checkESDHoldAndUpdateClaimStatusOnInsert(List<PartnerFundClaim> claimsTobeProcessed){
        // Set of Bank IDs from ClaimsToBeProcessed
        Set<ID> bankIDs = new Set<ID>();
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        for(PartnerFundClaim pfc: claimsTobeProcessed){
            //check if adjustment then break
            if(!Core_MDF_Claim_Utility.isType(pfc, Label.Core_MDF_Claim_Adjustment_Type))
            {
                bankIDs.add(pfc.Core_MDF_Bank__c);
                claimList.add(pfc);
            }
        }
        
        if(bankIDs != NULL && bankIDs.size() > 0){
           
            checkESDHoldAndUpdateClaimStatusForInsert(bankIDs,claimList);
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        validateBankMappingAndApplyHold
    @return  :          N/A
    @parameters:        List<PartnerFundClaim> object
    Description:        This method is called from claim trigger and used to update claim status,
    if claim bank status is 'Hold'
    Added By:           Accenture - AD - 11/12/2018
    Modified By:        Date:       Changes: 
    *******************************************************************************************************/
    public static void validateBankMappingAndApplyHold(Map<Id,PartnerFundClaim> newClaimMap,Map<Id,PartnerFundClaim> oldClaimMap){
        // Set of Bank IDs from ClaimsToBeProcessed 
        Set<ID> bankIDs = new Set<ID>();
       
        List<PartnerFundClaim> claimsTobeProcessed = new List<PartnerFundClaim>();
        for(PartnerFundClaim pfc: newClaimMap.values()){
            //check if adjustment then break
            if(Core_MDF_Claim_Utility.isType(pfc, Label.Core_MDF_Claim_Adjustment_Type)){ continue;}
            
            if(pfc.Id == oldClaimMap.get(pfc.Id).Id 
            && pfc.Core_MDF_Bank__c != oldClaimMap.get(pfc.Id).Core_MDF_Bank__c){
                
                bankIDs.add(pfc.Core_MDF_Bank__c);
                claimsTobeProcessed.add(pfc);
            }
            
        }
        
        if(bankIDs != NULL && bankIDs.size() > 0 && claimsTobeProcessed.size() >0){
            // Check ABM is active or not
                Core_MDF_Claim_Utility.validateABM(claimsTobeProcessed);
            //Checking bank ESD hold and updaing claim
            checkESDHoldAndUpdateClaimStatusForUpdate(bankIDs,claimsTobeProcessed,newClaimMap,oldClaimMap);
        }
    }

     /****************************************************************************************************** 
    Method Name:        checkESDHoldAndUpdateClaimStatusForInsert
    @return  :          N/A
    @parameters:        List<PartnerFundClaim> object
    Description:        This method is called from claim trigger and used to update claim status,
    if claim bank status is 'Hold'
    Added By:           Accenture - AD - 11/12/2018
    Modified By:        Date:       Changes: 
    *******************************************************************************************************
    *     VS            4/4/2019    Added condition to check if claim is Payment Hold and make it true
    *******************************************************************************************************/
    public static void checkESDHoldAndUpdateClaimStatusForInsert(Set<ID> bankIDs,List<PartnerFundClaim> claimListToBeProcessed){ 
        if(bankIDs !=null & bankIDs.size()>0){
            bankIdTobankInstance = new Map<ID,Core_MDF_Bank__c>([SELECT ID,Core_MDF_Bank_Status__c,Core_MDF_Bank_Location__c,Core_MDF_ESD_Hold_Indicator__c,Core_MDF_Hold_Payments_from_AP_file_ind__c,Core_MDF_VAT_pct__c,Core_MDF_Intel_Company_Code__c FROM Core_MDF_Bank__c WHERE ID IN:bankIDs]);
            
            List<PartnerFundClaim> claimsToBeReleased = new List<PartnerFundClaim>();
            if(claimListToBeProcessed!=null && claimListToBeProcessed.size()>0){
                for(PartnerFundClaim pfc : claimListToBeProcessed){ 
                    //check if adjustment then break
                    if(Core_MDF_Claim_Utility.isType(pfc, Label.Core_MDF_Claim_Adjustment_Type)){continue;}
                    if( bankIdTobankInstance.containsKey(pfc.Core_MDF_Bank__c) &&
                        bankIdTobankInstance.get(pfc.Core_MDF_Bank__c).Core_MDF_Bank_Status__c != NULL &&
                        Label.Core_MDF_Hold_Status.equals(bankIdTobankInstance.get(pfc.Core_MDF_Bank__c).Core_MDF_Bank_Status__c)
                    )
                    {
                        //commenting for PIC changes
                        //after PIC process
                        //pfc.Core_MDF_Status__c = Label.Core_MDF_Hold_Status;
                        if(bankIdTobankInstance.get(pfc.Core_MDF_Bank__c).Core_MDF_ESD_Hold_Indicator__c){                            
                            pfc.Core_MDF_ESD_Hold__c = true;
                        }
                        if(bankIdTobankInstance.get(pfc.Core_MDF_Bank__c).Core_MDF_Hold_Payments_from_AP_file_ind__c == 'Yes'){
                            pfc.Core_MDF_Payment_Hold_ind__c = true;
                        }  
                        //bankIdVatPercent.put(pfc.Core_MDF_Bank__c, bankIdTobankInstance.get(pfc.Core_MDF_Bank__c).Core_MDF_VAT_pct__c);
                    }
                }
            }
        }
    }
    
     /****************************************************************************************************** 
    Method Name:        checkESDHoldAndUpdateClaimStatusForUpdate
    @return  :          N/A
    @parameters:        List<PartnerFundClaim> object
    Description:        This method is called from claim trigger and used to update claim status,
    if claim bank status is 'Hold'
    Added By:           Accenture - AD - 11/12/2018
    Modified By:        Date:       Changes: 
    *********************************************************************************************************************
    *     VS            4/4/2019    Added condition to check if claim is Payment Hold or ESD Hold and release accordingly
    **********************************************************************************************************************/
    public static void checkESDHoldAndUpdateClaimStatusForUpdate(Set<ID> bankIDs,List<PartnerFundClaim> claimListToBeProcessed,Map<Id,PartnerFundClaim> inputClaimMap,Map<Id,PartnerFundClaim> oldClaimMap){
        List<String> claimPICStatuses = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ClaimPICStatus').split(';');
        if(bankIDs !=null & bankIDs.size()>0){
            bankIdTobankInstance = new Map<ID,Core_MDF_Bank__c>([SELECT ID,Core_MDF_Bank_Status__c,Core_MDF_Bank_Location__c,Core_MDF_ESD_Hold_Indicator__c,Core_MDF_Hold_Payments_from_AP_file_ind__c,Core_MDF_Program__c,Core_MDF_VAT_pct__c,Core_MDF_Intel_Company_Code__c FROM Core_MDF_Bank__c WHERE ID IN:bankIDs]);
            List<PartnerFundClaim> claimsToBeReleased = new List<PartnerFundClaim>();
            if(claimListToBeProcessed!=null && claimListToBeProcessed.size()>0){
                for(PartnerFundClaim pfc : claimListToBeProcessed){ 
                    
                    if(pfc == inputClaimMap.get(pfc.Id) &&
                        bankIdTobankInstance.containsKey(pfc.Core_MDF_Bank__c) &&
                        bankIdTobankInstance.get(pfc.Core_MDF_Bank__c).Core_MDF_Bank_Status__c != NULL &&
                        Label.Core_MDF_Hold_Status.equals(bankIdTobankInstance.get(pfc.Core_MDF_Bank__c).Core_MDF_Bank_Status__c)
                    )
                    {   
                      
                         //after PIC process  
                        if(pfc.Core_MDF_PIC_Review_Completed__c || (pfc.Core_MDF_Claim_Approval_Dt__c != null && pfc.Core_MDF_Approval_Step_Counter_nbr__c == 0)){
                            inputClaimMap.get(pfc.Id).Core_MDF_Status__c = Label.Core_MDF_Hold_Status;
                        }
                        if(bankIdTobankInstance.get(pfc.Core_MDF_Bank__c).Core_MDF_ESD_Hold_Indicator__c){
                            inputClaimMap.get(pfc.Id).Core_MDF_ESD_Hold__c = true; 
                        }else{
                            inputClaimMap.get(pfc.Id).Core_MDF_ESD_Hold__c = false;
                        }
                        if(bankIdTobankInstance.get(pfc.Core_MDF_Bank__c).Core_MDF_Hold_Payments_from_AP_file_ind__c == 'Yes'){
                            inputClaimMap.get(pfc.Id).Core_MDF_Payment_Hold_ind__c = true;
                        } else{
                           inputClaimMap.get(pfc.Id).Core_MDF_Payment_Hold_ind__c = false; 
                        }   
                    }//Scenario: If previous bank was on hold and current is active
                    else if(oldClaimMap.get(pfc.Id).Core_MDF_Status__c == Label.Core_MDF_Status_Hold || claimPICStatuses.contains(inputClaimMap.get(pfc.Id).Core_MDF_Status__c)){
                        //Add the Claims to the claimsToBeReleased list in order to release the hold
                        claimsToBeReleased.add(pfc);
                    }
                }
            }
            // Release the Hold for the claims added in claimsToBeReleased list
            if(claimsToBeReleased != NULL && claimsToBeReleased.size() > 0){
                for( PartnerFundClaim  claims :  claimsToBeReleased ){
                        Core_MDF_Claim_Utility.processReleaseHold(claimsToBeReleased, new List<String>{Label.Core_MDF_ESD_Hold, Label.Core_MDF_Payment_Hold});
                }             
            }  
        }
    }
}